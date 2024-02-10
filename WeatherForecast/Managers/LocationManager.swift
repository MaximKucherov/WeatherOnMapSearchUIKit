//
//  LocationManager.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 24/11/2023.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    
    private var locationManager = CLLocationManager()

    var currentLocation: CLLocationCoordinate2D? {
        locationManager.location?.coordinate
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

    // MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }

    // MARK: - Location permission
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location permission granted")
        case .denied:
            print("Location permission denied")
        default:
            break
        }
    }
}

