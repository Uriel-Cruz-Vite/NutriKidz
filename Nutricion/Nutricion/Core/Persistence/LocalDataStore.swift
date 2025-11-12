//
//  LocalDataStore.swift
//  Nutricion
//
//  Created by Uriel Cruz on 27/10/25.
//

import Foundation

import Foundation

final class LocalDataStore {
    static let shared = LocalDataStore()
    private init() {}

    // Cargar los alimentos desde foods.json
    func loadFoods() -> [Food] {
        guard let url = Bundle.main.url(forResource: "foods", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let foods = try? JSONDecoder().decode([Food].self, from: data) else {
            return []
        }
        return foods
    }
}
