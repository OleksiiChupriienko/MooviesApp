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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var watchTrailerButton: UIButton!

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

    private func rating(_ incoming: Double) -> String {
        var ratingString = ""
        let rating = Int(incoming)

        for star in 0..<10 {
            if star < rating {
                ratingString.append("★")
            } else {
                ratingString.append("☆")
            }
        }
        return ratingString
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
                DispatchQueue.main.async {
                    self.titleLabel.text = self.moovieDetails.title
                    self.genreLabel.text = self.moovieDetails.genres.first?.name
                    if let runtime = self.moovieDetails.runtime, runtime > 0 {
                        self.runtimeLabel.text = String(runtime) + " min"
                    }
                    self.ratingLabel.text = self.rating(self.moovieDetails.voteAverage)
                    self.overviewTextView.text = self.moovieDetails.overview
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

    @IBAction func watchTrailerButtonClicked(_ sender: Any) {
        let query = self.moovieDetails.title + " trailer"
        let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let appURL = URL(string: "youtube://www.youtube.com/results?search_query=\(escapedQuery!)")!
        let webURL = URL(string: "https://www.youtube.com/results?search_query=\(escapedQuery!)")!
        let application = UIApplication.shared

        if application.canOpenURL(appURL) {
            application.open(appURL, options: [:], completionHandler: nil)
        } else {
            application.open(webURL, options: [:], completionHandler: nil)
        }
    }
}
