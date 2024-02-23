//
//  CandidateModel.swift
//  PhotoEdit
//
//  Created by Onur Başdaş on 23.02.2024.
//

import Foundation

struct CandidateModel : Codable {
    let overlayId : Int?
    let overlayName : String?
    let overlayPreviewIconUrl : String?
    let overlayUrl : String?

    enum CodingKeys: String, CodingKey {
        case overlayId = "overlayId"
        case overlayName = "overlayName"
        case overlayPreviewIconUrl = "overlayPreviewIconUrl"
        case overlayUrl = "overlayUrl"
    }
}
