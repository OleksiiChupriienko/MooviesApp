//
//  DetailsController.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 11.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

class DetailsController: UIViewController {
    
    var moovieID: Int!
    var moovieDetails: DetailsResponse!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        fetchDetails()
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    private func fetchDetails() {
        MooviesAPI.shared.fetchDetails(moovieID: moovieID) { (result) in
            switch result {
            case .success(let details):
                self.moovieDetails = details
                print(self.moovieDetails)
            case .failure(let error):
                print(error)
            }
        }
    }

}
