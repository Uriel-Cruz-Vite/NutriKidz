//
//  MealPlanViewModel.swift
//  Nutricion
//
//  Created by Uriel Cruz on 27/10/25.
//



import SwiftUI
import Combine

@MainActor
final class MealPlanViewModel: ObservableObject {
    @Published var week: [MealDayPlan] = []
    @Published var selectedDay: Weekday = .monday

    private let foods: [Food] = LocalDataStore.shared.loadFoods()

    init() {
        if week.isEmpty { generateWeekPlan() }
    }

    func generateWeekPlan() {
        var result: [MealDayPlan] = []
        for day in Weekday.allCases {
            let breakfast = randomFood(prefer: ["Lácteo", "Pan", "Proteína"])
            let lunch     = randomFood(prefer: ["Grano", "Proteína", "Leguminosa", "Tubérculo"])
            let dinner    = randomFood(prefer: ["Proteína", "Lácteo", "Grano", "Tubérculo"])
            let morningSnack = randomFood(prefer: ["Fruta", "Lácteo", "Grano"])
            let eveningSnack = randomFood(prefer: ["Fruta", "Lácteo", "Proteína"])

            let slots: [MealSlot] = [
                .init(type: .breakfast,     food: breakfast),
                .init(type: .morningSnack,  food: morningSnack),
                .init(type: .lunch,         food: lunch),
                .init(type: .eveningSnack,  food: eveningSnack),
                .init(type: .dinner,        food: dinner)
            ]
            result.append(.init(day: day, meals: slots))
        }
        week = result
    }

    func clearPlan() { week.removeAll() }

    private func randomFood(prefer preferredCategories: [String]) -> Food? {
        guard !foods.isEmpty else { return nil }
        let preferred = foods.filter { preferredCategories.contains($0.category) }
        return (preferred.isEmpty ? foods : preferred).randomElement()
    }

    // Utilidad para sumar calorías del día (opcional para mostrar en UI)
    func calories(for day: Weekday) -> Int {
        guard let dayPlan = week.first(where: { $0.day == day }) else { return 0 }
        return dayPlan.meals.compactMap { $0.food?.calories }.reduce(0, +)
    }
}

