//
//  WeatherData.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 09/12/2023.
//

import Foundation

struct WeatherDetails: Codable  {
    let coord: Coord?
    let weather: [Weather]?
    let main: Main?
    let sys: Sys?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case coord
        case weather
        case main
        case sys
        case name
    }
}

struct Coord: Codable {
    let lat: Double?
    let lon: Double?
    
    enum CodingKeys: String, CodingKey {
        case lat
        case lon
    }
}

struct Weather: Codable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case main
        case description
        case icon
    }
}

struct Main: Codable {
    let temp: Double?
    let feels_like: Double?
    let humidity: Int?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feels_like
        case humidity
    }
}

struct Sys: Codable {
    let country: String?
    
    enum CodingKeys: String, CodingKey {
        case country
    }
}

