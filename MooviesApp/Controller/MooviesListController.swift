//
//  ViewController.swift
//  MooviesApp
//
//  Created by Aleksei Chupriienko on 09.09.2020.
//  Copyright © 2020 Andersen. All rights reserved.
//

import UIKit

class MooviesListController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mooviesTable: UITableView!

    // MARK: - Private Properties
    private var moovies: Moovies = []
    private var currentPage = 1
    private var isLoading = false
    private var totalCount = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        updateList()
    }

    override func viewWillAppear(_ animated: Bool) {
        setupVC()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let detailsVC = segue.destination as? DetailsController, let id = sender as? Int {
            detailsVC.moovieID = id
        }
    }

    // MARK: - Private Methods
    private func setupTableView() {
        registerCell()
        mooviesTable.dataSource = self
        mooviesTable.delegate = self
        mooviesTable.prefetchDataSource = self
    }

    private func setupVC() {
        self.navigationController?.navigationBar.isHidden = true
    }

    private func registerCell() {
        let nib = UINib(nibName: MoovieCell.id, bundle: nil)
        mooviesTable.register(nib, forCellReuseIdentifier: MoovieCell.id)
    }

    private func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= moovies.count
    }

    private func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = mooviesTable.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }

    private func calculateIndexPathsToReload(from newMoovies: Moovies) -> [IndexPath] {
        let startIndex = moovies.count - newMoovies.count
        let endIndex = startIndex + newMoovies.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }

    private func updateList() {
        self.isLoading.toggle()
        MooviesAPI.shared.fetchPopularMoovies(page: currentPage) { (result) in
            switch result {
            case .success(let response):
                self.totalCount = response.totalResults
                self.moovies.append(contentsOf: response.results)
                self.isLoading.toggle()
                self.currentPage += 1
                if response.page > 1 {
                    DispatchQueue.main.async {
                        let indexPathToReload = self.visibleIndexPathsToReload(intersecting:
                            self.calculateIndexPathsToReload(from: response.results))
                        self.mooviesTable.reloadRows(at: indexPathToReload, with: .automatic)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.mooviesTable.reloadData()
                    }
                }
            case .failure(let error):
                self.isLoading.toggle()
                print(error)
            }
        }
    }

}

// MARK: - extension UITableViewDataSource
extension MooviesListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoovieCell.id,
                                                       for: indexPath) as? MoovieCell
            else {
                fatalError("MoovieCell Error")
        }
        if isLoadingCell(for: indexPath) {

        } else {
            let moovie = moovies[indexPath.row]
            cell.moovieTitleLabel.text = moovie.title
            cell.moovieReleaseYearTitle.text = moovie.releaseDate
            cell.moovieRatingLabel.text = "⭐️ \(moovie.voteAverage)"
            if let posterPath = moovie.posterPath,
                let url = URL(string: MooviesAPI.mooviePosterEndpoint.appending(posterPath)) {
                cell.posterView.loadImage(at: url)
            } else {
                cell.posterView.image = UIImage(named: Constants.posterPlaceholderImage)
            }
        }
        return cell
    }

}

// MARK: - extension UITableViewDelegate
extension MooviesListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = tableView.superview?.safeAreaLayoutGuide.layoutFrame.height else {
            return 200
        }
        return height / 3
    }

    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        guard indexPath.row == moovies.count - 3, !isLoading else { return }
    //        updateList()
    //    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: Constants.showDetailsSegueID, sender: moovies[indexPath.row].id)
    }

}

extension MooviesListController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            updateList()
        }
    }

}
