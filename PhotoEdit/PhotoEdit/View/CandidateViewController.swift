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
    @IBOutlet weak var selectedOverlayImage: UIImageView!
    
    let viewModel = CandidateViewModel()
    private var panGesture: UIPanGestureRecognizer?
    private var pinchGesture: UIPinchGestureRecognizer?
    private var pinchScale: CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupOverlayGestures()
    }
    
    private func setupUI() {
        candidateCollectionView.delegate = self
        candidateCollectionView.dataSource = self
        candidateCollectionView.register(CandidateCollectionViewCell.nib(), forCellWithReuseIdentifier: CandidateCollectionViewCell.identifier)
        candidateImageView.image = UIImage(named: "ic_image")
        getData()
        setupGestures()
    }
    
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        selectedOverlayImage.isUserInteractionEnabled = true
        selectedOverlayImage.addGestureRecognizer(panGesture!)
    }
    
    private func setupOverlayGestures() {
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        selectedOverlayImage.isUserInteractionEnabled = true
        selectedOverlayImage.addGestureRecognizer(pinchGesture!)
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
        selectedOverlayImage.image = nil
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        saveMergedImage()
    }
    
    private func saveMergedImage() {
        guard let baseImage = candidateImageView.image, let overlayImage = selectedOverlayImage.image else { return }
        let scale = pinchScale
        let panTranslation = CGPoint(x: selectedOverlayImage.transform.tx, y: selectedOverlayImage.transform.ty)
        let mergedImage = baseImage.merge(with: overlayImage, alpha: 0.5, panTranslation: panTranslation, pinchScale: scale)
        UIView.transition(with: selectedOverlayImage, duration: 0, options: .transitionCrossDissolve, animations: {
            self.selectedOverlayImage.image = mergedImage
            self.selectedOverlayImage.transform = .identity
            self.pinchScale = 1.0
        }, completion: nil)

        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: mergedImage)
                request.creationDate = Date()
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.showAlert(title: Constants.success, message: Constants.successMessage)
                        self.selectedOverlayImage.image = nil
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
            imageView.transform = imageView.transform.translatedBy(x: translation.x, y: translation.y)
            gesture.setTranslation(.zero, in: imageView)
        }
    }

    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let overlayImageView = gesture.view as? UIImageView else { return }

        if gesture.state == .began || gesture.state == .changed {
            pinchScale *= gesture.scale
            overlayImageView.transform = overlayImageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1.0
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
                self.selectedOverlayImage.image = overlayImage
                self.applyBitmapOverlay(image: self.selectedOverlayImage.image ?? UIImage(), overlayImage: overlayImage) { resultImage in
                    if let resultImage = resultImage {
                        self.selectedOverlayImage.image = resultImage
                    } else {
                        print("Failed to apply overlay")
                    }
                }
            }
        }
    }
}
