//
//  CandidateViewController.swift
//  PhotoEdit
//
//  Created by Onur on 23.02.2024.
//

import UIKit

class CandidateViewController: UIViewController {
    
    @IBOutlet weak var candidateCollectionView: UICollectionView!
    
    let viewModel = CandidateViewModel()
    var candidateArray: [CandidateModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        candidateCollectionView.delegate = self
        candidateCollectionView.dataSource = self
        candidateCollectionView.register(CandidateCollectionViewCell.nib(), forCellWithReuseIdentifier: CandidateCollectionViewCell.identifier)
        getData()
    }
    
    func getData() {
        viewModel.fetchCandidateData { result in
            switch result {
            case .success(let candidateArray):
                self.candidateArray = candidateArray
                DispatchQueue.main.async {
                    self.candidateCollectionView.reloadData()
                }

            case .failure(let error):
                switch error {
                case .invalidURL:
                    print("Geçersiz URL")
                case .noData:
                    print("Veri bulunamadı")
                case .decodingError(let decodingError):
                    print("Decode hatası: \(decodingError)")
                }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        print("cancel")
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        print("save")
    }
    
}

extension CandidateViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return candidateArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = candidateCollectionView.dequeueReusableCell(withReuseIdentifier: CandidateCollectionViewCell.identifier, for: indexPath) as! CandidateCollectionViewCell
        cell.bind(data: candidateArray[indexPath.row])
        return cell
    }
}
