//
//  Constants.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 10.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

enum Constants {

    enum Colors {
        static let lightShadowColor = UIColor.lightGray.cgColor
        static let darkShadowColor = UIColor.darkGray.cgColor
        static let detailsOrangeColor = UIColor(red: 1, green: 113/255, blue: 13/255, alpha: 1)
    }

    enum Links {
        static let appURL = "youtube://www.youtube.com/results?search_query="
        static let webURL = "https://www.youtube.com/results?search_query="
    }

    enum Identifiers {
        static let posterPlaceholderImage = "placeholderImage"
        static let detailsViewControllerID = "detailsController"
    }

}
