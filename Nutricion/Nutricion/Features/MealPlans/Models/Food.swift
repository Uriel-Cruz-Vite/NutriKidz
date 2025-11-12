//
//  Food.swift
//  Nutricion
//
//  Created by Uriel Cruz on 27/10/25.
//

import Foundation

struct Food: Identifiable, Codable {
    let id: UUID
    let name: String
    let calories: Int
    let category: String
    // NUEVO (opcionales, no rompen nada):
    let ingredients: [String]?
    let steps: [String]?
}
