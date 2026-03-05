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
        if let targetKcal {
            self.targetKcal = targetKcal > 0 ? targetKcal : nil
        }
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
            var usedFoodIDs = Set<UUID>()
            var remainingCalories = self.targetKcal
            var remainingPercent = 1.0

            for (index, mealSpec) in distribution.enumerated() {
                let (type, percent, preferredCats) = mealSpec
                let quota = quotaFor(
                    index: index,
                    totalMeals: distribution.count,
                    mealPercent: percent,
                    remainingCalories: remainingCalories,
                    remainingPercent: remainingPercent
                )
                let picked = pickFoodClosest(
                    to: quota,
                    withinPreferred: preferredCats,
                    excluding: usedFoodIDs
                )
                slots.append(.init(type: type, food: picked))

                if let picked {
                    usedFoodIDs.insert(picked.id)
                }
                if let kcal = picked?.calories, let currentRemaining = remainingCalories {
                    remainingCalories = max(0, currentRemaining - kcal)
                }
                remainingPercent = max(0, remainingPercent - percent)
            }

            result.append(.init(day: day, meals: slots))
        }

        week = result
    }

    func clearPlan() { week.removeAll() }

    // MARK: - Helpers

    /// Si hay targetKcal, calcula una cuota dinámica para acercar mejor el total diario.
    private func quotaFor(
        index: Int,
        totalMeals: Int,
        mealPercent: Double,
        remainingCalories: Int?,
        remainingPercent: Double
    ) -> Int? {
        guard let remainingCalories, remainingCalories > 0 else { return nil }
        let isLastMeal = index == totalMeals - 1
        if isLastMeal { return remainingCalories }

        guard remainingPercent > 0 else { return remainingCalories }
        let normalizedPercent = mealPercent / remainingPercent
        return Int((Double(remainingCalories) * normalizedPercent).rounded())
    }

    /// Elige el alimento cuya caloría esté más cerca de la cuota objetivo.
    /// Si no hay cuota (targetKcal nil), cae al random por categorías preferidas.
    private func pickFoodClosest(
        to quota: Int?,
        withinPreferred preferredCategories: [String],
        excluding excludedIDs: Set<UUID>
    ) -> Food? {
        guard !foods.isEmpty else { return nil }

        // Sin meta establecida, mantener comportamiento anterior (aleatorio por preferencia).
        guard let quota else {
            return randomFood(prefer: preferredCategories, excluding: excludedIDs)
        }

        let preferred = foods.filter { preferredCategories.contains($0.category) }
        let basePool = preferred.isEmpty ? foods : preferred
        let pool = filteredPool(from: basePool, excluding: excludedIDs)

        // Elegir entre los más cercanos evita planes deterministas al regenerar.
        let sortedByDistance = pool.sorted { abs($0.calories - quota) < abs($1.calories - quota) }
        let candidateCount = min(4, sortedByDistance.count)
        return Array(sortedByDistance.prefix(candidateCount)).randomElement()
    }

    private func randomFood(prefer preferredCategories: [String], excluding excludedIDs: Set<UUID>) -> Food? {
        guard !foods.isEmpty else { return nil }
        let preferred = foods.filter { preferredCategories.contains($0.category) }
        let basePool = preferred.isEmpty ? foods : preferred
        let pool = filteredPool(from: basePool, excluding: excludedIDs)
        return pool.randomElement()
    }

    private func filteredPool(from pool: [Food], excluding excludedIDs: Set<UUID>) -> [Food] {
        let filtered = pool.filter { !excludedIDs.contains($0.id) }
        return filtered.isEmpty ? pool : filtered
    }

    // Utilidad para sumar calorías del día (para mostrar en UI)
    func calories(for day: Weekday) -> Int {
        guard let dayPlan = week.first(where: { $0.day == day }) else { return 0 }
        return dayPlan.meals.compactMap { $0.food?.calories }.reduce(0, +)
    }
}
