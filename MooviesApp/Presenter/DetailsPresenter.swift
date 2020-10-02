//
//  DetailsPresenter.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 02.10.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import Foundation

class DetailsPresenter {
    private var mooviesAPI: MooviesAPI
    private weak var view: DetailsView?

    init(mooviesAPI: MooviesAPI) {
        self.mooviesAPI = mooviesAPI
    }

    func attachView(view: DetailsView) {
        self.view = view
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

    func getInfo() {
        if let view = self.view {
            mooviesAPI.fetchDetails(moovieID: view.id) { (result) in
                switch result {
                case .success(let detailMoovie):
                    let dataToPresent = DetailMoovieViewData(posterPath:
                        detailMoovie.posterPath, backdropPath:
                        detailMoovie.posterPath, rating:
                        self.rating(detailMoovie.voteAverage), title: detailMoovie.title, genre:
                        detailMoovie.genres.map {$0.name}.joined(separator: ", "), overview:
                        detailMoovie.overview, runtime:
                        detailMoovie.runtime != nil ? String(detailMoovie.runtime!) + " min" : "")
                    view.setDetails(details: dataToPresent)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

}
