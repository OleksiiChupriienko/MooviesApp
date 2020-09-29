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

    var mooviesAPI: MooviesAPI!
    
    // MARK: - Private Properties
    private var moovies: Moovies = []
    private var filteredMoovies: Moovies = []
    private var currentPage = 1
    private var isLoading = false
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupTableView()
        updateList()
    }

    // MARK: - Private Methods
    private func setupTableView() {
        registerCell()
        mooviesTable.dataSource = self
        mooviesTable.delegate = self
    }

    private func setupVC() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter moovie title"
        navigationItem.searchController = searchController
        navigationItem.title = "Popular moovies"
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func registerCell() {
        let nib = UINib(nibName: MoovieCell.id, bundle: nil)
        mooviesTable.register(nib, forCellReuseIdentifier: MoovieCell.id)
    }

    private func updateList() {
        self.isLoading.toggle()
        mooviesAPI.fetchPopularMoovies(page: currentPage) { (result) in
            switch result {
            case .success(let response):
                let startIndex = self.moovies.count
                self.moovies.append(contentsOf: response.results)
                let endIndex = self.moovies.count
                if self.currentPage > 1 {
                    DispatchQueue.main.async {
                        self.mooviesTable.beginUpdates()
                        self.mooviesTable.insertRows(at:
                            (startIndex..<endIndex).map { IndexPath(row: $0, section: 0)}, with: .automatic)
                        self.mooviesTable.endUpdates()
                    }
                } else {
                    DispatchQueue.main.async {
                         self.mooviesTable.reloadData()
                    }
                }
                self.isLoading.toggle()
                self.currentPage += 1
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
        searchBarIsEmpty ? moovies.count : filteredMoovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoovieCell.id,
                                                       for: indexPath) as? MoovieCell
            else {
                fatalError("MoovieCell Error")
        }

        let moovie = searchBarIsEmpty ? moovies[indexPath.row] : filteredMoovies[indexPath.row]
            cell.moovieTitleLabel.text = moovie.title
            cell.moovieReleaseYearTitle.text = moovie.releaseDate
            cell.moovieRatingLabel.text = "⭐️ \(moovie.voteAverage)"
            if let posterPath = moovie.posterPath,
                let url = URL(string: MooviesAPI.mooviePosterEndpoint.appending(posterPath)) {
                cell.posterView.loadImage(at: url)
            } else {
                cell.posterView.image = UIImage(named: Constants.Identifiers.posterPlaceholderImage)
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let bottom = scrollView.contentSize.height - scrollView.bounds.height

        if offsetY >= bottom - (mooviesTable.visibleCells.first?.bounds.height ?? 200), !isLoading, searchBarIsEmpty {
            updateList()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let moovieID = moovies[indexPath.row].id
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: Constants.Identifiers.detailsViewControllerID) as? DetailsController {
            detailsVC.moovieID = moovieID
            detailsVC.mooviesAPI = self.mooviesAPI
            detailsVC.navigationController?.navigationItem.hidesBackButton = true
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }

}

extension MooviesListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    private func filterContentForSearchText(_ searchText: String) {
        filteredMoovies = moovies.filter({ $0.title.lowercased().contains(searchText.lowercased()) })
        mooviesTable.reloadData()
    }

}
