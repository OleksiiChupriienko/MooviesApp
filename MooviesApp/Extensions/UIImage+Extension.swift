//
//  UIImage+Extension.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 10.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadPoster(posterPath: String) {
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: posterPath as AnyObject) {
            image = imageFromCache as? UIImage
            return
        }
        
        MooviesAPI.shared.fetchPoster(posterPath: posterPath) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let dataString):
                guard let data = Data(base64Encoded: dataString), let imageToCache = UIImage(data: data) else { return }
                imageCache.setObject(imageToCache, forKey: posterPath as AnyObject)
                DispatchQueue.main.async {
                    self.image = imageToCache
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.image = UIImage(named: Constants.posterPlaceholderImage)
                }
            }
        }
    }
}
