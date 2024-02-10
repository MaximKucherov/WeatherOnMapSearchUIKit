//
//  FilterService.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 09/12/2023.
//

import Foundation

struct FilterService: Hashable {
    let name: String?
    let lat: Double?
    let lon: Double?
    let country: String?
    let state: String?
    
    // Реализация Hashable для уникальности
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(country)
        hasher.combine(state)
    }
    
    static func == (lhs: FilterService, rhs: FilterService) -> Bool {
        return lhs.name == rhs.name &&
        lhs.country == rhs.country &&
        lhs.state == rhs.state
    }
}
