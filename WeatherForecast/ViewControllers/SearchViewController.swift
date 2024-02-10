//
//  SearchViewController.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 23/11/2023.
//

import UIKit
import MapKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    weak var delegate: TabBarBadgeDelegate?
    
    private let viewModel = SearchViewModel()
    private let searchController = UISearchController(searchResultsController: nil)
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .black
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    // Let's add an initializer to pass the delegate
    init(delegate: TabBarBadgeDelegate?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        configureSearchController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.updateTabBarBadge(count: StorageManager.shared.fetchData().count)
    }
}

    //MARK: - Setup SearchViewController
extension SearchViewController {
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = .white
        searchController.searchBar.searchTextField.leftView?.tintColor = .purple
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.foregroundColor: UIColor.purple], for: .normal)
        searchController.searchBar.delegate = self
        
        searchController.isActive = true
    }
}

    // MARK: - TableView
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white

        let weatherInfo = viewModel.searchResults[indexPath.row]
        
        cell.textLabel?.text = "\(weatherInfo.name ?? ""), \(weatherInfo.state ?? ""), \(weatherInfo.country ?? "")"
        
        // Adding a custom image with a white arrow
        let disclosureImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        disclosureImageView.tintColor = .white
        cell.accessoryView = disclosureImageView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedWeatherInfo = viewModel.searchResults[indexPath.row]
        
        let detailVC = DetailViewController()
        detailVC.cityLocation = selectedWeatherInfo
        
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

    // MARK: - UpdateSearchResults
extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchTerm = searchController.searchBar.text else { return }

        viewModel.fetchLocationData(for: searchTerm) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
