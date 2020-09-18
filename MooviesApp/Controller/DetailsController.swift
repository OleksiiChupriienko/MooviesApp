//
//  DetailsController.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 11.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

class DetailsController: UIViewController {

    @IBOutlet weak var backdropView: UIImageView!
    @IBOutlet weak var posterView: UIImageView!

    var moovieID: Int!
    var moovieDetails: DetailMoovie!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        self.posterView.layer.cornerRadius = 5
        fetchDetails()
    }

    private func setupNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }

    private func fetchDetails() {
        MooviesAPI.shared.fetchDetails(moovieID: moovieID) { (result) in
            switch result {
            case .success(let details):
                self.moovieDetails = details
                if let backPath = self.moovieDetails.backdropPath,
                    let url = URL(string: MooviesAPI.moovieBackdropPathEndpoint.appending(backPath)) {
                     self.backdropView.loadImage(at: url)
                }
                if let posterPath = self.moovieDetails.posterPath,
                    let url = URL(string: MooviesAPI.mooviePosterEndpoint.appending(posterPath)) {
                     self.posterView.loadImage(at: url)
                }
                print(self.moovieDetails)
            case .failure(let error):
                print(error)
            }
        }
    }

    @IBAction func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }

}
