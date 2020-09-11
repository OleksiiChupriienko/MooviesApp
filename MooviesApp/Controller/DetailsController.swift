//
//  DetailsController.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 11.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

class DetailsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }

}
