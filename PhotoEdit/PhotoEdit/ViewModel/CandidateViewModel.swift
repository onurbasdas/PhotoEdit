//
//  CandidateViewModel.swift
//  PhotoEdit
//
//  Created by Onur Başdaş on 23.02.2024.
//

import Foundation
import UIKit
import Photos

class CandidateViewModel {
    
    private var candidateArray: [CandidateModel] = []
    
    func getCandidateCount() -> Int {
        return candidateArray.count
    }
    
    func getCandidate(at index: Int) -> CandidateModel? {
        guard index >= 0, index < candidateArray.count else {
            return nil
        }
        return candidateArray[index]
    }
    
    func setCandidateArray(_ array: [CandidateModel]) {
        candidateArray = array
    }
    
    func fetchCandidateData(completion: @escaping (Result<[CandidateModel], NetworkError>) -> Void) {
        NetworkLayer.shared.fetchOverlayData { result in
            switch result {
            case .success(let candidateArray):
                completion(.success(candidateArray))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
