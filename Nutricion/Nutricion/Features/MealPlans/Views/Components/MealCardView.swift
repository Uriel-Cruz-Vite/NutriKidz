//
//  MealCardView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 29/10/25.
//

import SwiftUI

struct MealCardView: View {
    let slot: MealSlot

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.secondary.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: slot.type.systemIcon)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.green)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(slot.type.rawValue)
                    .font(.callout.weight(.semibold))
                    .foregroundColor(.secondary)

                Text(slot.food?.name ?? "Sin asignar")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if let kcal = slot.food?.calories {
                    Text("\(kcal) kcal • \(slot.food?.category ?? "")")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("Añade un platillo")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        )
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    let food = Food(
        id: UUID(),
        name: "Huevo",
        calories: 155,
        category: "Proteína",
        ingredients: ["Huevo", "Aceite de oliva", "Sal"],
        steps: ["Calentar el sartén", "Agregar aceite", "Cocinar el huevo a tu gusto"]
    )
    let slot = MealSlot(type: .breakfast, food: food)
    MealCardView(slot: slot)
        .padding()
        .background(Color(.systemGroupedBackground))
}
