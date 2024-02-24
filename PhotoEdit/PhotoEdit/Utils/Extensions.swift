//
//  Extensions.swift
//  PhotoEdit
//
//  Created by Onur Başdaş on 24.02.2024.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension UIImage {
    func merge(with overlay: UIImage, alpha: CGFloat, transform: CGAffineTransform) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        self.draw(at: .zero)
        overlay.draw(
            in: CGRect(origin: CGPoint(x: transform.tx, y: transform.ty), size: self.size),
            blendMode: .normal,
            alpha: alpha
        )
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return mergedImage ?? self
    }
}
