//
//  ViewController.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 09.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

class MooviesListController: UIViewController {

    @IBOutlet weak var mooviesTable: UITableView!
    
    var moovies: Moovies = []
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        updateList(page: currentPage)
    }
    
    private func setupTableView() {
        registerCell()
        mooviesTable.dataSource = self
        mooviesTable.delegate = self
    }
    
    private func registerCell() {
        let nib = UINib(nibName: Constants.moovieCellReuseID, bundle: nil)
        mooviesTable.register(nib, forCellReuseIdentifier: Constants.moovieCellReuseID)
    }
    
    private func updateList(page: Int) {
        MooviesAPI.shared.fetchPopularMoovies(page: currentPage) { (result) in
            switch result {
            case .success(let response):
                self.moovies.append(contentsOf: response.results)
                DispatchQueue.main.async {
                    self.mooviesTable.reloadData()
                }
                self.currentPage += 1
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

extension MooviesListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        moovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.moovieCellReuseID, for: indexPath) as? MoovieCell
            else {
                fatalError("MoovieCell Error")
        }
        let moovie = moovies[indexPath.row]
        cell.moovieTitleLabel.text = moovie.title
        cell.moovieReleaseYearTitle.text = moovie.releaseDate
        cell.moovieRatingLabel.text = "⭐️ \(moovie.voteAverage)"
        if let posterPath = moovie.posterPath {
            cell.posterView.loadPoster(posterPath: posterPath)
        }
        return cell
    }
    
    
}

extension MooviesListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = tableView.superview?.safeAreaLayoutGuide.layoutFrame.height else {
            return 200
        }
        return height / 3
    }
}
