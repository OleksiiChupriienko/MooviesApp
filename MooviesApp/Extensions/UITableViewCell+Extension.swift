//
//  UITableViewCell+Extension.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 14.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static var id: String {
        NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
