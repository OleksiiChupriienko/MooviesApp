//
//  UIImageLoader.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 11.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

class UIImageLoader {
    
    static let shared = UIImageLoader()
    
    private let imageLoader = ImageLoader()
    private var uuidMap = [UIImageView: UUID]()
    
    private init() {}
    
    func load(_ url: URL, for imageView: UIImageView) {
        let token = imageLoader.loadImage(url: url) { (result) in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    imageView.image = image
                }
            case .failure(_):
                DispatchQueue.main.async {
                    imageView.image = UIImage(named: Constants.posterPlaceholderImage)
                }
            }
        }
        if let token = token {
            uuidMap[imageView] = token
        }
    }
    
    func cancel(for imageView: UIImageView) {
        if let uuid = uuidMap[imageView] {
            imageLoader.cancelLoad(uuid)
            uuidMap.removeValue(forKey: imageView)
        }
    }
    
    
}
