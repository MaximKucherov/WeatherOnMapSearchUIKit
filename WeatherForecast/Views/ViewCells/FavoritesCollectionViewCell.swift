//
//  FavoritesCollectionViewCell.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 01/12/2023.
//

import Foundation
import UIKit
import MapKit

class FavoritesCollectionViewCell: UICollectionViewCell {
    
    var mapView: MKMapView!
    var containerView: UIView!
    var infoStackView: UIStackView!
    var cityNameLabel: UILabel!
    var countryNameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
            mapView = MKMapView()
            mapView.translatesAutoresizingMaskIntoConstraints = false
        
            mapView.showsUserLocation = true
            mapView.isZoomEnabled = false
            mapView.isScrollEnabled = false
            mapView.isUserInteractionEnabled = false // Prohibit the movement of the map in cells
        
            contentView.addSubview(mapView)
            mapView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

            // Adding the containerView from below
            containerView = UIView()
        containerView.backgroundColor = .darkGray
            containerView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(containerView)
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
            containerView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.3).isActive = true

            // StackView
            infoStackView = UIStackView()
            infoStackView.axis = .vertical
            infoStackView.spacing = 8
            infoStackView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(infoStackView)
            infoStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
            infoStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
            infoStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
            infoStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8).isActive = true

            cityNameLabel = UILabel()
            cityNameLabel.textColor = .white
            cityNameLabel.text = "CityNameLabel"
            cityNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
            countryNameLabel = UILabel()
            countryNameLabel.textColor = .white
            countryNameLabel.text = "CountryNameLabel"
            countryNameLabel.font = UIFont.systemFont(ofSize: 14)

            infoStackView.addArrangedSubview(cityNameLabel)
            infoStackView.addArrangedSubview(countryNameLabel)
        }
}


