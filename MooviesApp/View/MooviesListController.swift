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
    private var mooviesToDisplay: [MoovieViewData] = []
    private var filteredMoovies: [MoovieViewData] = []
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }
    var presenter: MooviesListPresenter!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupTableView()
        presenter.attachView(view: self)
        presenter.getMoovies()
    }

    // MARK: - Private Methods
    private func setupTableView() {
        registerCell()
        mooviesTable.dataSource = self
        mooviesTable.delegate = self
        mooviesTable.keyboardDismissMode = .onDrag
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

}

// MARK: - extension UITableViewDataSource
extension MooviesListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchBarIsEmpty ? mooviesToDisplay.count : filteredMoovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoovieCell.id,
                                                       for: indexPath) as? MoovieCell
            else {
                fatalError("MoovieCell Error")
        }

        let moovie = searchBarIsEmpty ? mooviesToDisplay[indexPath.row] : filteredMoovies[indexPath.row]
        cell.moovieTitleLabel.text = moovie.title
        cell.moovieReleaseYearTitle.text = moovie.releaseDate
        cell.moovieRatingLabel.text = moovie.rating
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
        if offsetY >= bottom - (mooviesTable.visibleCells.first?.bounds.height ?? 200), !presenter.isLoading, searchBarIsEmpty {
            presenter.getMoovies()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let moovieID = searchBarIsEmpty ? mooviesToDisplay[indexPath.row].id : filteredMoovies[indexPath.row].id
        presenter.moovieID = moovieID
        presenter.showDetails(row: indexPath.row, moovieID: moovieID)
    }

}

extension MooviesListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredMoovies = mooviesToDisplay.filter({ $0.title.lowercased().contains(searchController.searchBar.text!.lowercased()) })
        mooviesTable.reloadData()
    }

}

extension MooviesListController: MooviesListView {
    func showDetails(nextPresenter: DetailsPresenter) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailsVC = storyboard.instantiateViewController(withIdentifier:
            Constants.Identifiers.detailsViewControllerID) as? DetailsController {
            detailsVC.presenter = nextPresenter
            detailsVC.moovieID = presenter.moovieID
            navigationController?.pushViewController(detailsVC, animated: true)
        }

    }

    func setMoovies(moovies: [MoovieViewData]) {
        let startIndex = self.mooviesToDisplay.count
        self.mooviesToDisplay.append(contentsOf: moovies)
        let endIndex = self.mooviesToDisplay.count
        DispatchQueue.main.async {
            if self.presenter.currentPage > 1 {
                self.mooviesTable.beginUpdates()
                self.mooviesTable.insertRows(at:
                    (startIndex..<endIndex).map { IndexPath(row: $0, section: 0)}, with: .automatic)
                self.mooviesTable.endUpdates()
            } else {
                self.mooviesTable.reloadData()
            }
        }
    
    }

}
