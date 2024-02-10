//
//  FavoriteViewModel.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 12/12/2023.
//

import Foundation

class FavoriteViewModel {
    
    func fetchData() -> [CityLocationEntity] {
        StorageManager.shared.fetchData()
    }
    
    // We use computed property so that every time we access favoriteCells, the fetchData method is called and returns the reversed data
    var reversedCells: [CityLocationEntity] {
        fetchData().reversed()
    }
    
}
