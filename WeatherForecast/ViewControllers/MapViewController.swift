//
//  ViewController.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 23/11/2023.
//

import MapKit

class MapViewController: UIViewController{
    
    weak var delegate: TabBarBadgeDelegate?
    
    private var mapView: MKMapView!
    private var segmentedControl: UISegmentedControl!
    
    private let viewModel = MapViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupNavigationMapPanel()
        setupLongPressGesture()
        delegate?.updateTabBarBadge(count: StorageManager.shared.fetchData().count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.updateTabBarBadge(count: StorageManager.shared.fetchData().count)
    }
}

    // MARK: - Setup MapView
extension MapViewController {
    
    private func setupMapView() {
        mapView = MKMapView()
        mapView.frame = view.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        // Display the user's current location
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        view.addSubview(mapView)
    }
    
    private func setupNavigationMapPanel() {
        
        // Creating a UISegmentedControl with two segments
        segmentedControl = UISegmentedControl(items: [NSLocalizedString("Standard", comment: ""), NSLocalizedString("Satellite", comment: "")])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        segmentedControl.tintColor = .gray
        segmentedControl.selectedSegmentTintColor = .gray
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        
        // Creating a UIButton with a location image
        let locationButton = UIButton(type: .system)
        locationButton.setImage(UIImage(systemName: "location"), for: .normal)
        locationButton.tintColor = .purple
        locationButton.addTarget(self, action: #selector(locationButtonPressed), for: .touchUpInside)

        // Creating a UIStackView to host UISegmentedControl and UIImageView
        let stackView = UIStackView(arrangedSubviews: [segmentedControl, locationButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 100

        // Creating an additional UIView with a black background
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
            backgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Installing UIStackView in an additional UIView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -8)
        ])
    
        // Adding a dividing line
        let separatorLine = UIView()
        separatorLine.backgroundColor = .gray
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separatorLine)
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorLine.topAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .ended else { return }
        
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        reverseGeocodeAndAddMarker(coordinate: coordinate)
    }
    
    private func reverseGeocodeAndAddMarker(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemark = placemarks?.first, error == nil else {
                // Handle reverse geocoding errors
                return
            }
            
            let locationName = placemark.name ?? placemark.locality ?? placemark.subLocality ?? ""
            self.addMarker(coordinate: coordinate, title: locationName)
        }
    }
    
    private func addMarker(coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0: mapView.mapType = .standard
            case 1: mapView.mapType = .satellite
            default: break
        }
    }
    
    @objc private func locationButtonPressed() {
        if let userLocation = viewModel.getCurrentUserLocation() {
            mapView.setCenter(userLocation, animated: true)
        }
    }
}

    // MARK: - MapViewDelegate
extension MapViewController: MKMapViewDelegate {
    // Implement MKMapViewDelegate methods if needed
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinate = view.annotation?.coordinate else { return }
        let detailViewController = DetailViewController()
        
        viewModel.updateDetailWeather(latitude: coordinate.latitude, longitude: coordinate.longitude) { result in
            switch result {
            case .success(let weatherData):
                guard let city = weatherData.name,
                        let latitude = weatherData.coord?.lat,
                        let longitude = weatherData.coord?.lon,
                        let state = Optional(""),
                        let country = weatherData.sys?.country
                else { return }
                    let cityLocation = FilterService(name: city, lat: latitude, lon: longitude, country: country, state: state)
                    detailViewController.cityLocation = cityLocation
            case .failure(let failure):
                print("Error: \(failure)")
            }
        }
        
//        detailViewController.updateLocationData(latitude: coordinate.latitude, longitude: coordinate.longitude)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
