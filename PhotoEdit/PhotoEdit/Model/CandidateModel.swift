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

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        overlayId = try values.decodeIfPresent(Int.self, forKey: .overlayId)
        overlayName = try values.decodeIfPresent(String.self, forKey: .overlayName)
        overlayPreviewIconUrl = try values.decodeIfPresent(String.self, forKey: .overlayPreviewIconUrl)
        overlayUrl = try values.decodeIfPresent(String.self, forKey: .overlayUrl)
    }
}
