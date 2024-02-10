//
//  MapViewModel.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 12/12/2023.
//

import Foundation
import MapKit

class MapViewModel {
    
    private let locationManager = LocationManager()
    private let weatherService = WeatherApiService()
    
    func getCurrentUserLocation() -> CLLocationCoordinate2D? {
        locationManager.currentLocation
    }
    
    func updateDetailWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherDetails, Error>) -> Void) {
        
        weatherService.fetchDetailsData(lat: latitude, lon: longitude) { result in
            switch result {
            case .success(let detailsData):
                completion(.success(detailsData))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
}
