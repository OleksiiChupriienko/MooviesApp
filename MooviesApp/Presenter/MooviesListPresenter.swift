//
//  MooviesListPresenter.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 02.10.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import Foundation

protocol MooviesListView: class {
    func setMoovies(moovies: [MoovieViewData])
    func showDetails(nextPresenter: DetailsPresenter)
}

class MooviesListPresenter {
    private let mooviesAPI: MooviesAPI
    weak private var mooviesListView: MooviesListView?
    private(set) var currentPage = 1
    private(set) var isLoading = false
    var moovieID: Int?

    init(mooviesAPI: MooviesAPI) {
        self.mooviesAPI = mooviesAPI
    }

    func attachView(view: MooviesListView) {
        mooviesListView = view
    }

    func getMoovies() {
        if !isLoading {
            isLoading.toggle()
            mooviesAPI.fetchPopularMoovies(page: currentPage) { [weak self] (result) in
                switch result {
                case .success(let popularMoovies):
                    let dataToPresent = popularMoovies.results.map { MoovieViewData(title:
                        $0.title, releaseDate: $0.releaseDate, rating:
                        "⭐️ \($0.voteAverage)", posterPath: $0.posterPath, id: $0.id)}
                    self?.mooviesListView?.setMoovies(moovies: dataToPresent)
                    self?.currentPage += 1
                    self?.isLoading.toggle()
                case .failure(let error):
                    self?.isLoading.toggle()
                    print(error)
                }
            }
        }
    }

    func showDetails(row: Int, moovieID: Int) {
        let presenter = DetailsPresenter(mooviesAPI: self.mooviesAPI)
        presenter.moovieID = moovieID
        mooviesListView?.showDetails(nextPresenter: presenter)
    }
}
