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
    @IBOutlet weak var candidateImageView: UIImageView!
    
    let viewModel = CandidateViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        candidateCollectionView.delegate = self
        candidateCollectionView.dataSource = self
        candidateCollectionView.register(CandidateCollectionViewCell.nib(), forCellWithReuseIdentifier: CandidateCollectionViewCell.identifier)
        getData()
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
//        candidateImageView.addGestureRecognizer(tapGesture)
//        candidateImageView.isUserInteractionEnabled = true
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
        clearImage()
    }
    
    private func clearImage() {
        candidateImageView.image = nil
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        saveImageToPhotos()
    }
    
//    @objc private func handleImageTap() {
//        showImagePicker()
//    }
//    private func showImagePicker() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary
//        present(imagePicker, animated: true, completion: nil)
//    }
    
    private func saveImageToPhotos() {
        guard let imageToSave = candidateImageView.image else {
            showAlert(title: Constants.error, message: Constants.errorMessage)
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Permission denied to access photo library.")
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: imageToSave)
                request.creationDate = Date()
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.showAlert(title: Constants.success, message: Constants.successMessage)
                    } else {
                        self.showAlert(title: Constants.error, message: "Failed to save image. \(error?.localizedDescription ?? "")")
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
                guard let overlayImage = overlayImage else {
                    print("Failed to load overlay image")
                    return
                }
                
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

extension CandidateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            candidateImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//core graphics for bitmap operation
