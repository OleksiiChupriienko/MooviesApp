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

    private var query: String?

    var moovieID: Int!
    var presenter: DetailsPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        self.posterView.layer.cornerRadius = 5
        presenter.attachView(view: self)
        presenter.getInfo()
    }

    private func setupNavigationBar() {
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    @IBAction func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func watchTrailerButtonClicked(_ sender: Any) {
        if var query = self.query {
            query += " trailer"
            let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let appURL = URL(string: Constants.Links.appURL.appending(escapedQuery!))!
            let webURL = URL(string: Constants.Links.webURL.appending(escapedQuery!))!
            let application = UIApplication.shared

            if application.canOpenURL(appURL) {
                application.open(appURL, options: [:], completionHandler: nil)
            } else {
                application.open(webURL, options: [:], completionHandler: nil)
            }
        }
    }

}

extension DetailsController: DetailsView {
    func setDetails(details: DetailMoovieViewData) {
        self.query = details.title
        if let backPath = details.backdropPath,
            let url = URL(string: MooviesAPI.moovieBackdropPathEndpoint.appending(backPath)) {
             self.backdropView.loadImage(at: url)
        }
        if let posterPath = details.posterPath,
            let url = URL(string: MooviesAPI.mooviePosterEndpoint.appending(posterPath)) {
             self.posterView.loadImage(at: url)
        }
        DispatchQueue.main.async {
            self.titleLabel.text = details.title
            self.genreLabel.text = details.genre
            self.runtimeLabel.text = details.runtime
            self.ratingLabel.text = details.rating
            self.overviewTextView.text = details.overview
        }
    }

}
