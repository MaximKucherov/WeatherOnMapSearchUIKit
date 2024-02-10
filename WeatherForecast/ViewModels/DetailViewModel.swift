//
//  DetailViewModel.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 12/12/2023.
//

import Foundation
import UIKit

enum FetchImageError: Error {
    case invalidURL
    case imageConversionError
    case networkError(Error)
    case unknownError
}

class DetailViewModel {
    
    private let weatherService = WeatherApiService()
    private var humidity: Int?
    private var temperatura: Double?
    
    // city -> Name, Latitude, Longitude, Country, State
    func updateByLocationName(for searchTerm: String, completion: @escaping (Result<[CityLocation], Error>) -> Void) {
        weatherService.fetchByLocationName(for: searchTerm) { result in
            switch result {
            case .success(let cityCountry):
                completion(.success((cityCountry)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // latitude, longitude -> name, Coord(latitude, longitude), Weather(description, icon), Main(temp, feels_like, humidity), Sys(country)
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
    
    // iconCode -> image
    func getFetchImage(iconCode: String, completion: @escaping (Result<UIImage, FetchImageError>) -> Void) {
        let iconURLString = "https://openweathermap.org/img/w/\(iconCode).png"
        
        guard let iconURL = URL(string: iconURLString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let request = URLRequest(url: iconURL)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, error == nil {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        let newSize = CGSize(width: 25, height: 25)
                        let resizedImage = image.resized(to: newSize)
                        completion(.success(resizedImage))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.imageConversionError))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error ?? FetchImageError.unknownError)))
                }
            }
        }.resume()
    }
    
    func getWeekdaysForCells() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"

        var components = DateComponents()
        components.day = 1

        if let nextDay = Calendar.current.date(byAdding: components, to: Date()) {
            let nextDayWeekday = dateFormatter.string(from: nextDay)
            return nextDayWeekday
        }
        return ""
    }
    
    // The values are random because OpenWeatherMap does't provide this data for free now!!!
    func getRandomHumidity(humidity: Int) -> Int {
        let value = [-30, -20, -10, 20, 10, 30]
        var addRandomHumidity = humidity + (value.randomElement() ?? -10)
        
        if addRandomHumidity > 90 {
            let value = [-50, -40, -30, -20, -10]
            addRandomHumidity = humidity + (value.randomElement() ?? -10)
        }
        return addRandomHumidity - addRandomHumidity % 10
    }
    
    // The values are random because OpenWeatherMap does't provide this data for free now!!!
    func getRandomTemp(temperature: Double) -> Int {
        let randomTemp = Double.random(in: -2...2)
        let tempCels = temperature - 273.15
        return Int(tempCels + randomTemp)
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
