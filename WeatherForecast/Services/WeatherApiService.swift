//
//  WeatherService.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 03/12/2023.
//

import Foundation
import Alamofire

class WeatherApiService {
    private let apiKey: String

    init(apiKey: String = "4d13a2108055a784c356ef325ef40ec4") {
        self.apiKey = apiKey
    }

    // city -> Name, Latitude, Longitude, Country, State
    func fetchByLocationName(for city: String, completion: @escaping (Result<[CityLocation], Error>) -> Void) {
        let url = "https://api.openweathermap.org/geo/1.0/direct?q=\(city)&limit=5&appid=\(apiKey)"
        
      AF.request(url)
        .validate()
        .responseDecodable(of: [CityLocation].self) { response in
          switch response.result {
          case .success(let cityCountry):
            completion(.success(cityCountry))
          case .failure(let error):
            completion(.failure(error))
          }
        }
    }

    func fetchDetailsData(lat: Double, lon: Double, completion: @escaping (Result<WeatherDetails, Error>) -> Void) {
        let lang = NSLocalizedString("lang", comment: "")
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&\(lang)"
        
        AF.request(url)
        .validate()
        .responseDecodable(of: WeatherDetails.self) { response in
            switch response.result {
            case .success(let weatherDetails):
                completion(.success(weatherDetails))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchLocationApi(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherDetails, Error>) -> Void) {
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        
        AF.request(url)
        .validate()
        .responseDecodable(of: WeatherDetails.self) { response in
            switch response.result {
            case .success(let locationData):
                completion(.success(locationData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


