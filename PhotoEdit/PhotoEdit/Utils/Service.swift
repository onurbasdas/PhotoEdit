//
//  Service.swift
//  PhotoEdit
//
//  Created by Onur Başdaş on 23.02.2024.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
}

class NetworkLayer {
    static let shared = NetworkLayer()

    private init() {}

    func fetchOverlayData(completion: @escaping (Result<[CandidateModel], NetworkError>) -> Void) {
        guard let url = URL(string: "https://lyrebirdstudio.s3-us-west-2.amazonaws.com/candidates/overlay.json") else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.decodingError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let decoder = JSONDecoder()
                let candidates = try decoder.decode([CandidateModel].self, from: data)
                completion(.success(candidates))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}
