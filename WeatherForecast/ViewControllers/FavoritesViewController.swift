//
//  FavoritesViewController.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 23/11/2023.
//

import UIKit
import MapKit
import CoreData

class FavoritesViewController: UIViewController {
        
    weak var delegate: TabBarBadgeDelegate?
    
    private let viewModel = FavoriteViewModel()
    private var collectionView: UICollectionView!
    private let cellId = "cell"
    
    // Let's add an initializer to pass the delegate
    init(delegate: TabBarBadgeDelegate?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        collectionView.register(FavoritesCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.updateTabBarBadge(count: StorageManager.shared.fetchData().count)
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = .black
    }
}

    // MARK: - CollectionViewDataSource, ollectionViewDelegateFlowLayout
extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.reversedCells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavoritesCollectionViewCell
        
        let favoriteCell = viewModel.reversedCells[indexPath.row]
        cell.cityNameLabel.text = favoriteCell.name
        cell.countryNameLabel.text = favoriteCell.country
        
        // Set the coordinates for each cell
        let cityCoordinate = CLLocationCoordinate2D(latitude: favoriteCell.lat, longitude: favoriteCell.lon)
        
        // Shifting the center up
        let yOffset = -0.03
        let adjustedCoordinate = CLLocationCoordinate2D(latitude: cityCoordinate.latitude + yOffset, longitude: cityCoordinate.longitude)
        
        // Set the coordinates for each cell
        let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        let region = MKCoordinateRegion(center: adjustedCoordinate, span: span)
        
        cell.mapView.setRegion(region, animated: false)
        
        // Rounding the corners of a cell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true // So that the rounding of the corners is applied
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // We set the same indentation between the cells on all sides
        let spacing: CGFloat = 5.0
        let collectionViewWidth = collectionView.bounds.width
        let availableWidth = collectionViewWidth - (spacing * 2) // we take into account the three indents between the four cells
        let cellWidth = availableWidth / 2
        let cellHeight = cellWidth // to keep the aspect ratio
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // Setting the minimum distance between the lines
        return 10.0
    }
}

    // MARK: - Collection View Delegate
extension FavoritesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCellData = viewModel.reversedCells[indexPath.row]
        let detailViewController = DetailViewController()
        
        // Set the data to be displayed in the DetailViewController
        detailViewController.cityLocation = FilterService(name: selectedCellData.name, 
                                                          lat: selectedCellData.lat,
                                                          lon: selectedCellData.lon,
                                                          country: selectedCellData.country,
                                                          state: selectedCellData.state
        )

        navigationController?.pushViewController(detailViewController, animated: true)
    }
        
}
