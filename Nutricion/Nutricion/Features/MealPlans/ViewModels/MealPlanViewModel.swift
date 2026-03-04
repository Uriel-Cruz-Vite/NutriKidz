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

    // Meta calórica diaria opcional para ajustar el plan
    @Published var targetKcal: Int?

    private let foods: [Food] = LocalDataStore.shared.loadFoods()

    init(targetKcal: Int? = nil) {
        self.targetKcal = targetKcal
        if week.isEmpty { generateWeekPlan(targetKcal: targetKcal) }
    }

    /// Genera el plan semanal. Si se proporciona targetKcal, intenta aproximar
    /// la suma diaria a esa meta repartiendo por comidas.
    func generateWeekPlan(targetKcal: Int? = nil) {
        if let targetKcal { self.targetKcal = targetKcal }
        var result: [MealDayPlan] = []

        // Porcentajes de distribución por comida (ajustables)
        let distribution: [(MealType, Double, [String])] = [
            (.breakfast,     0.25, ["Lácteo", "Pan", "Proteína", "Grano"]),
            (.morningSnack,  0.10, ["Fruta", "Lácteo", "Grano"]),
            (.lunch,         0.35, ["Grano", "Proteína", "Leguminosa", "Tubérculo"]),
            (.eveningSnack,  0.10, ["Fruta", "Lácteo", "Proteína"]),
            (.dinner,        0.20, ["Proteína", "Lácteo", "Grano", "Tubérculo"])
        ]

        for day in Weekday.allCases {
            var slots: [MealSlot] = []

            for (type, percent, preferredCats) in distribution {
                let quota = quotaFor(typePercent: percent)
                let picked = pickFoodClosest(to: quota, withinPreferred: preferredCats)
                slots.append(.init(type: type, food: picked))
            }

            result.append(.init(day: day, meals: slots))
        }

        week = result
    }

    func clearPlan() { week.removeAll() }

    // MARK: - Helpers

    private func randomFood(prefer preferredCategories: [String]) -> Food? {
        guard !foods.isEmpty else { return nil }
        let preferred = foods.filter { preferredCategories.contains($0.category) }
        return (preferred.isEmpty ? foods : preferred).randomElement()
    }

    /// Si hay targetKcal, calcula la cuota para esa comida. Si no, devuelve nil.
    private func quotaFor(typePercent: Double) -> Int? {
        guard let target = targetKcal, target > 0 else { return nil }
        return Int((Double(target) * typePercent).rounded())
    }

    /// Elige el alimento cuya caloría esté más cerca de la cuota objetivo.
    /// Si no hay cuota (targetKcal nil), cae al random por categorías preferidas.
    private func pickFoodClosest(to quota: Int?, withinPreferred preferredCategories: [String]) -> Food? {
        guard !foods.isEmpty else { return nil }

        // Sin meta establecida, mantener comportamiento anterior (aleatorio por preferencia).
        guard let quota else {
            return randomFood(prefer: preferredCategories)
        }

        let preferred = foods.filter { preferredCategories.contains($0.category) }
        let pool = preferred.isEmpty ? foods : preferred

        // Minimizar la diferencia absoluta con la cuota objetivo.
        return pool.min(by: { abs($0.calories - quota) < abs($1.calories - quota) })
    }

    // Utilidad para sumar calorías del día (para mostrar en UI)
    func calories(for day: Weekday) -> Int {
        guard let dayPlan = week.first(where: { $0.day == day }) else { return 0 }
        return dayPlan.meals.compactMap { $0.food?.calories }.reduce(0, +)
    }
}

