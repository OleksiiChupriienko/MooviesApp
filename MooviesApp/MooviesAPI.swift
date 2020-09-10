//
//  MooviesAPI.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 10.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import Foundation

class MooviesAPI {
    
    static let shared = MooviesAPI()
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    private enum APIError: Error {
        case invalidURL
        case serverDoNotResponse
        case serverResponseError
        case canNotReceiveData
    }
    
    private init() {}
    
    func fetchPopularMoovies(page: Int, completion: @escaping (Result<APIResponse, Error>) -> Void) {
        fetchData(from: Constants.popularMooviesEndpoint.appending("?page=\(page)"), completion: completion)
    }
    
    private func fetchData<Object: Decodable>(from url: String, completion: @escaping (Result<Object, Error>) -> Void) {
        request(url: url) { (result) in
            switch result {
            case .success(let data):
                do {
                    let object = try self.decoder.decode(Object.self, from: data)
                    completion(.success(object))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func request(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        let headerFields = ["Authorization" : "Bearer " + Constants.apiKey,
                            "Content-Type" : "application/json;charset=utf-8"]
        request.allHTTPHeaderFields = headerFields
        let task = session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                completion(.failure(error))
            }
            guard let responseUnwrapped = urlResponse as? HTTPURLResponse else {
                completion(.failure(APIError.serverDoNotResponse))
                return
            }
            switch responseUnwrapped.statusCode {
            case 200:
                guard let data = data else {
                    completion(.failure(APIError.canNotReceiveData))
                    return
                }
                completion(.success(data))
            default:
                completion(.failure(APIError.serverResponseError))
            }
        }
        task.resume()
    }
}
