//
//  CityCountry.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 09/12/2023.
//

import Foundation

struct CityLocation: Codable {
    let name: String?
    let lat: Double?
    let lon: Double?
    let country: String?
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case lat
        case lon
        case country
        case state
    }
}

