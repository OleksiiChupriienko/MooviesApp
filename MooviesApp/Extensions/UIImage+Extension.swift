//
//  UIImage+Extension.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 10.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

extension UIImageView {
  func loadImage(at url: URL) {
    UIImageLoader.shared.load(url, for: self)
  }

  func cancelImageLoad() {
    UIImageLoader.shared.cancel(for: self)
  }
}
