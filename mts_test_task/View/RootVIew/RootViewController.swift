//
//  RootViewController.swift
//  mts_test_task
//
//  Created by  Matvey on 08.04.2021.
//

import UIKit

class RootViewController: UIViewController {
    
    private let tableView = UITableView()
    private let indicator: UIActivityIndicatorView = {
       let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        indicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    private let noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Sorry, no photos for your search"
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    private var refreshControl = UIRefreshControl()
    
    private var items: [NasaObject] = []
    private var searchPage = 1
    private var debounceTimer: Timer?
    
    private var networkService = NetworkService()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupLayout()
        setupTable()
        setupSearchBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Most Popular"
        requestPopularList()
        setupActions()
    }
    
    // MARK: Setup UI
    private func setupLayout() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        var constraints: [NSLayoutConstraint] = []
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false;
        let tableConstraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        constraints += tableConstraints
        
        view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false;
        let indicatorConstraints = [
            indicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            indicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
        ]
        constraints += indicatorConstraints
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func generateOkAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        return alert
    }
    
    private func switchToLoadState(_ isLoad: Bool) {
        if isLoad {
            indicator.startAnimating()
            showNoDataLabel(false)
            tableView.isHidden = true
        } else {
            indicator.stopAnimating()
            tableView.isHidden = false
        }
    }
    
    private func showNoDataLabel(_ isNoData: Bool) {
        if isNoData {
            view.addSubview(noDataLabel)
            view.bringSubviewToFront(noDataLabel)
            let oldFrame = noDataLabel.frame
            noDataLabel.frame = CGRect(x: oldFrame.minX,
                                       y: oldFrame.minY,
                                       width: tableView.frame.width - 32,
                                       height: 50)
            noDataLabel.center = tableView.center
        } else {
            noDataLabel.removeFromSuperview()
        }
    }
    
    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(InfoCell.self, forCellReuseIdentifier: String(describing: InfoCell.self))
        tableView.separatorStyle = .none
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }
}

// MARK: Actions
extension RootViewController {
    private func setupActions() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.backgroundView = refreshControl
    }
    
    @objc
    private func refresh() {
        requestPopularList()
        refreshControl.endRefreshing()
    }
}

// MARK: UITableViewDelegate
extension RootViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController(nasaObject: items[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: UITableViewDataSource
extension RootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: InfoCell.self)) as? InfoCell else { return UITableViewCell() }
        let item = items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

//MARK: UISearchBarDelegate
extension RootViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        switchToLoadState(true)
        searchPage = 1
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] (_) in
            self?.searchResueatList(searchTerm: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        requestPopularList()
        searchPage = 1
    }
}

//MARK: Network
extension RootViewController {
    
    private func requestPopularList() {
        switchToLoadState(true)
        networkService.getPopolarList { [weak self] (result) in
            self?.switchToLoadState(false)
            switch result {
            case .failure(let error):
                let alert = self?.generateOkAlert(title: "Error", message: error.localizedDescription)
                if let alert = alert {
                    self?.present(alert, animated: true)
                }
            case .success(let list):
                self?.items = list
                self?.tableView.reloadData()
            }
        }
    }
    
    private func searchResueatList(searchTerm: String,_ page: Int = 1) {
        networkService.getSearchResult(searchTerm: searchTerm, page: page) { [weak self] (result) in
            self?.switchToLoadState(false)
            switch result {
            case .failure(let error):
                let alert = self?.generateOkAlert(title: "Error", message: error.localizedDescription)
                if let alert = alert {
                    self?.present(alert, animated: true)
                }
            case .success(let list):
                if list.isEmpty && page == 1 {
                    self?.showNoDataLabel(true)
                }
                self?.items = list
                self?.tableView.reloadData()
            }
        }
    }
}
