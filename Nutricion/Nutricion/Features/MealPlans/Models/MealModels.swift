//
//  MealModels.swift
//  Nutricion
//
//  Created by Uriel Cruz on 29/10/25.
//

import Foundation

enum Weekday: Int, CaseIterable, Identifiable {
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday
    var id: Int { rawValue }

    var shortTitle: String {
        switch self {
        case .monday: return "Lun"
        case .tuesday: return "Mar"
        case .wednesday: return "Mié"
        case .thursday: return "Jue"
        case .friday: return "Vie"
        case .saturday: return "Sáb"
        case .sunday: return "Dom"
        }
    }

    var fullTitle: String {
        switch self {
        case .monday: return "Lunes"
        case .tuesday: return "Martes"
        case .wednesday: return "Miércoles"
        case .thursday: return "Jueves"
        case .friday: return "Viernes"
        case .saturday: return "Sábado"
        case .sunday: return "Domingo"
        }
    }
}

enum MealType: String, CaseIterable, Identifiable {
    case breakfast = "Desayuno"
    case morningSnack = "Colación matutina"
    case lunch     = "Comida"
    case eveningSnack = "Colación vespertina"
    case dinner    = "Cena"
    var id: String { rawValue }

    var systemIcon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .morningSnack: return "leaf"
        case .lunch:     return "fork.knife"
        case .eveningSnack: return "cup.and.saucer.fill"
        case .dinner:    return "moon.stars.fill"
        }
    }
}

struct MealSlot: Identifiable {
    let id = UUID()
    let type: MealType
    let food: Food?
}

struct MealDayPlan: Identifiable {
    let id = UUID()
    let day: Weekday
    var meals: [MealSlot]   // 5: desayuno, colación matutina, comida, colación vespertina, cena
}
