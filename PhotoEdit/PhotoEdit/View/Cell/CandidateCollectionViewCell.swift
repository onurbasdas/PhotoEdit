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
    
    override var isSelected: Bool {
         didSet {
             updateAppearance()
         }
     }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    func updateAppearance() {
        if isSelected {
            candidateImageView.layer.borderColor = UIColor.cyan.cgColor
            candidateImageView.layer.borderWidth = 2.0
            candidateLabel.textColor = UIColor.cyan
        } else {
            candidateImageView.layer.borderWidth = 0.0
            candidateLabel.textColor = .black
        }
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
                        self?.updateAppearance()
                    }
                }.resume()
            }
        }
    }
}
