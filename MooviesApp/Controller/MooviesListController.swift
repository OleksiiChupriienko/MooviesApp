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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupTableView()
        updateList()
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
    }

    private func setupVC() {
        self.navigationController?.navigationBar.isHidden = true
    }

    private func registerCell() {
        let nib = UINib(nibName: MoovieCell.id, bundle: nil)
        mooviesTable.register(nib, forCellReuseIdentifier: MoovieCell.id)
    }

    private func updateList() {
        self.isLoading.toggle()
        MooviesAPI.shared.fetchPopularMoovies(page: currentPage) { (result) in
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
        moovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoovieCell.id,
                                                       for: indexPath) as? MoovieCell
            else {
                fatalError("MoovieCell Error")
        }

            let moovie = moovies[indexPath.row]
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

        if offsetY >= bottom - (mooviesTable.visibleCells.first?.bounds.height ?? 200), !isLoading {
            updateList()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: Constants.Identifiers.showDetailsSegueID, sender: moovies[indexPath.row].id)
    }

}
