//
//  CandidateViewModel.swift
//  PhotoEdit
//
//  Created by Onur Başdaş on 23.02.2024.
//

import Foundation

class CandidateViewModel {
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
