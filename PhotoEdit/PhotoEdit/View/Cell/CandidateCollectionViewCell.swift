//
//  CandidateCollectionViewCell.swift
//  PhotoEdit
//
//  Created by Onur Başdaş on 23.02.2024.
//

import UIKit

class CandidateCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CandidateCollectionViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "CandidateCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet weak var candidateBgView: UIView!
    @IBOutlet weak var candidateImageView: UIImageView!
    @IBOutlet weak var candidateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    func configureUI() {
        candidateImageView.layer.cornerRadius = 10
    }
    
    func bind(data: CandidateModel) {
        if data.overlayId == 0 {
            candidateLabel.text = "None"
            candidateImageView.image = UIImage(named: "ic_none")
        } else {
            candidateLabel.text = data.overlayName
            if let url = URL(string: data.overlayPreviewIconUrl) {
                URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
                    guard let data = data, error == nil else {
                        return
                    }
                    DispatchQueue.main.async {
                        self?.candidateImageView.image = UIImage(data: data)
                    }
                }.resume()
            }
        }
    }
}
