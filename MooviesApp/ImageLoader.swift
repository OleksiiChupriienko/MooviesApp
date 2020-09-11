//
//  ImageLoader.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 11.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

class ImageLoader {
    
    private var loadedImages = NSCache<AnyObject, AnyObject>()
    private var runningRequests = [UUID: URLSessionDataTask]()
    
    private enum ImageLoadingError: Error {
        case noImageAndNoError
    }
    
    func loadImage(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        if let image = loadedImages.object(forKey: url as AnyObject) as? UIImage {
            completion(.success(image))
            return nil
        }
        
        let uuid = UUID()
        
        var request = URLRequest(url: url)
        let headerFields = ["Authorization" : "Bearer " + Constants.apiKey,
                            "Content-Type" : "application/json;charset=utf-8"]
        request.allHTTPHeaderFields = headerFields
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                self.runningRequests.removeValue(forKey: uuid)
            }
            
            if let error = error, (error as NSError).code != NSURLErrorCancelled {
              completion(.failure(error))
              return
            }
            
            if let data = data, let imageData = Data(base64Encoded: data.base64EncodedString()), let image = UIImage(data: imageData) {
                self.loadedImages.setObject(image, forKey: url as AnyObject)
                completion(.success(image))
                return
            }
        }
        task.resume()
        
        runningRequests[uuid] = task
        return uuid
    }
    
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
    
    
}
