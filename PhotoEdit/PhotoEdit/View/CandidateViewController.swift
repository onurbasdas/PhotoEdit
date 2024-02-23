//
//  CandidateViewController.swift
//  PhotoEdit
//
//  Created by Onur on 23.02.2024.
//

import UIKit
import Photos

class CandidateViewController: UIViewController {
    
    @IBOutlet weak var candidateCollectionView: UICollectionView!
    @IBOutlet weak var candidateImageBgView: UIView!
    @IBOutlet weak var candidateImageView: UIImageView!
    
    let viewModel = CandidateViewModel()
    private var panGesture: UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        candidateCollectionView.delegate = self
        candidateCollectionView.dataSource = self
        candidateCollectionView.register(CandidateCollectionViewCell.nib(), forCellWithReuseIdentifier: CandidateCollectionViewCell.identifier)
        getData()
        setupGestures()
    }
    
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        candidateImageView.isUserInteractionEnabled = true
        candidateImageView.addGestureRecognizer(panGesture!)
    }
    
    func getData() {
        viewModel.fetchCandidateData { result in
            switch result {
            case .success(let candidateArray):
                self.viewModel.setCandidateArray(candidateArray)
                DispatchQueue.main.async {
                    self.candidateCollectionView.reloadData()
                }
            case .failure(let error):
                switch error {
                case .invalidURL:
                    print("Invalid URL")
                case .noData:
                    print("No Data")
                case .decodingError(let decodingError):
                    print("Decode error: \(decodingError)")
                }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        clearOverlay()
    }
    
    private func clearOverlay() {
        candidateImageView.image = UIImage(named: "ic_image")
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        saveImageToPhotos()
    }
    
    private func saveImageToPhotos() {
        guard let imageToSave = candidateImageView.image else { return }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: imageToSave)
                request.creationDate = Date()
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.showAlert(title: Constants.success, message: Constants.successMessage)
                    } else {
                        self.showAlert(title: Constants.error, message: Constants.errorMessage)
                    }
                }
            }
        }
    }
    
    private func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        if let imageUrl = URL(string: url) {
            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }.resume()
        } else {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    private func applyBitmapOverlay(image: UIImage, overlayImage: UIImage, completion: @escaping (UIImage?) -> Void) {
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        image.draw(in: rect)
        overlayImage.draw(in: rect, blendMode: .normal, alpha: 0.5)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        completion(newImage)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
         guard let imageView = gesture.view else { return }
         
         if gesture.state == .began || gesture.state == .changed {
             let translation = gesture.translation(in: imageView)
             imageView.frame.origin.x += translation.x
             imageView.frame.origin.y += translation.y
             gesture.setTranslation(.zero, in: imageView)
         }
     }
}

extension CandidateViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getCandidateCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = candidateCollectionView.dequeueReusableCell(withReuseIdentifier: CandidateCollectionViewCell.identifier, for: indexPath) as? CandidateCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let candidate = viewModel.getCandidate(at: indexPath.row) {
            cell.bind(data: candidate)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let overlayUrl = viewModel.getCandidate(at: indexPath.row)?.overlayUrl {
            loadImage(from: overlayUrl) { overlayImage in
                guard let overlayImage = overlayImage else { return }
                
                if let currentImage = self.candidateImageView.image {
                    self.applyBitmapOverlay(image: currentImage, overlayImage: overlayImage) { resultImage in
                        if let resultImage = resultImage {
                            self.candidateImageView.image = resultImage
                        } else {
                            print("Failed to apply overlay")
                        }
                    }
                }
            }
        }
    }
}
