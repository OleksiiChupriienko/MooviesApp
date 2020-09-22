//
//  IconButton.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 21.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

@IBDesignable
class IconButton: UIButton {
    @IBInspectable var pointSize:CGFloat = 30.0

    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: pointSize)
            setPreferredSymbolConfiguration(config, forImageIn: .normal)
        } else {
            // Fallback on earlier versions
        }
    }
}
