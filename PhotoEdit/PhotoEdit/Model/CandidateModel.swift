//
//  CandidateModel.swift
//  PhotoEdit
//
//  Created by Onur Başdaş on 23.02.2024.
//

import Foundation
import UIKit

class CandidateModel: Codable {
    var overlayId: Int
    var overlayName: String
    var overlayPreviewIconUrl: String
    var overlayUrl: String

    init(overlayId: Int, overlayName: String, overlayPreviewIconUrl: String, overlayUrl: String) {
        self.overlayId = overlayId
        self.overlayName = overlayName
        self.overlayPreviewIconUrl = overlayPreviewIconUrl
        self.overlayUrl = overlayUrl
    }
}
