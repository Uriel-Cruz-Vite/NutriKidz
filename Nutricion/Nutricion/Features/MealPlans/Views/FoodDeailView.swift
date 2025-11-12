//
//  FoodDetailView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 29/10/25.
//

import SwiftUI

struct FoodDetailView: View {
    let food: Food?
    let mealType: MealType

    @State private var section: DetailSection = .ingredientes

    // MARK: - Theme
    private var accent: Color { .green }
    private var headerGradient: LinearGradient {
        LinearGradient(colors: [accent.opacity(0.35), accent.opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Encabezado visual mejorado
                header

                // Información básica
                infoCard

                // Picker de sección: Ingredientes / Receta
                sectionPicker

                // Contenido según la sección
                Group {
                    switch section {
                    case .ingredientes:
                        ingredientsView
                    case .receta:
                        recipeView
                    }
                }
                .padding(.top, 2)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity
                ))
                .animation(.spring(duration: 0.45, bounce: 0.2), value: section)

                Spacer(minLength: 12)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(
            // Fondo sutil con gradiente y material para un look moderno
            ZStack {
                LinearGradient(colors: [Color(.systemBackground), accent.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                Color.clear.background(.regularMaterial)
            }
            .ignoresSafeArea()
        )
        .navigationTitle(mealType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subvistas

    private var header: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(headerGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(accent.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: accent.opacity(0.15), radius: 12, x: 0, y: 8)
                .frame(height: 140)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.thinMaterial)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Circle().stroke(accent.opacity(0.2), lineWidth: 1)
                        )
                    Image(systemName: mealType.systemIcon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(food?.name ?? "Sin asignar")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.primary)
                        if let category = food?.category, !category.isEmpty {
                            Text(category)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    Capsule().stroke(accent.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }

                    Text(food != nil ? "\(food!.calories) kcal" : "Selecciona un platillo")
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    if let food, food.calories > 0 {
                        // Indicador visual simple de calorías
                        CalorieProgress(calories: food.calories)
                            .padding(.top, 6)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
        }
    }

    private var infoCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                row(label: "Tipo de comida", value: mealType.rawValue, systemImage: mealType.systemIcon)
                Divider().opacity(0.15)
                row(label: "Categoría", value: food?.category ?? "—", systemImage: "tag")
                Divider().opacity(0.15)
                row(label: "Calorías", value: food != nil ? "\(food!.calories) kcal" : "—", systemImage: "flame.fill")
            }
            .padding(.top, 2)
        } label: {
            Label("Información", systemImage: "info.circle.fill")
                .font(.headline)
        }
        .groupBoxStyle(ModernGroupBoxStyle(accent: accent))
    }

    private var sectionPicker: some View {
        Picker("Sección", selection: $section) {
            Label("Ingredientes", systemImage: "list.bullet").tag(DetailSection.ingredientes)
            Label("Receta", systemImage: "book.fill").tag(DetailSection.receta)
        }
        .pickerStyle(.segmented)
        .padding(.top, 2)
        .tint(accent)
    }

    private var ingredientsView: some View {
        GroupBox {
            if let food {
                let list = food.ingredients ?? suggestedIngredients(for: food)
                if list.isEmpty {
                    EmptyStateView(title: "Sin ingredientes", subtitle: "No hay ingredientes disponibles para este platillo.")
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(list, id: \.self) { item in
                            HStack(alignment: .firstTextBaseline, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(accent)
                                    .font(.system(size: 14))
                                Text(item)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                EmptyStateView(title: "Agrega un platillo", subtitle: "Selecciona un platillo para ver los ingredientes.")
            }
        } label: {
            Label("Ingredientes", systemImage: "list.bullet")
                .font(.headline)
        }
        .groupBoxStyle(ModernGroupBoxStyle(accent: accent))
    }

    private var recipeView: some View {
        GroupBox {
            if let food {
                let steps = food.steps ?? suggestedRecipeSteps(for: food)
                if steps.isEmpty {
                    EmptyStateView(title: "Sin receta", subtitle: "No hay pasos de preparación disponibles.")
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(idx + 1).")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(accent)
                                Text(step)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                EmptyStateView(title: "Agrega un platillo", subtitle: "Selecciona un platillo para ver la receta.")
            }
        } label: {
            Label("Receta", systemImage: "book.fill")
                .font(.headline)
        }
        .groupBoxStyle(ModernGroupBoxStyle(accent: accent))
    }

    // MARK: - Filas y helpers

    private func row(label: String, value: String) -> some View {
        row(label: label, value: value, systemImage: nil)
    }

    private func row(label: String, value: String, systemImage: String?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(accent)
                    .imageScale(.medium)
                    .frame(width: 18)
            }
            Text(label)
                .foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Text(value)
                .font(.body.weight(.medium))
        }
        .contentShape(Rectangle())
    }

    private func suggestedIngredients(for food: Food) -> [String] {
        // Sugerencias simples basadas en la categoría.
        switch food.category {
        case "Proteína":
            return ["120 g de \(food.name.lowercased())", "Sal y pimienta", "1 cda de aceite"]
        case "Grano":
            return ["1 taza de \(food.name.lowercased()) cocido", "Agua o caldo", "Pizca de sal"]
        case "Lácteo":
            return ["1 vaso de \(food.name.lowercased())", "Opcional: canela o cacao"]
        case "Leguminosa":
            return ["1 taza de \(food.name.lowercased()) cocida", "Ajo, cebolla", "Pizca de sal"]
        case "Tubérculo":
            return ["1 pieza de \(food.name.lowercased())", "Pizca de sal", "1 cdita de aceite"]
        default:
            return ["\(food.name)", "Ingredientes a tu elección"]
        }
    }

    private func suggestedRecipeSteps(for food: Food) -> [String] {
        switch food.category {
        case "Proteína":
            return ["Sazona la proteína.", "Calienta el aceite y dora 3–4 min por lado.", "Sirve con vegetales."]
        case "Grano":
            return ["Enjuaga el grano si aplica.", "Cocina en agua/caldo hasta suave.", "Ajusta sal y sirve."]
        case "Lácteo":
            return ["Sirve en vaso.", "Opcional: aromatiza con canela/cacao.", "Consume frío o tibio."]
        case "Leguminosa":
            return ["Sofríe ajo y cebolla.", "Agrega leguminosa cocida y calienta.", "Ajusta sal y sirve."]
        case "Tubérculo":
            return ["Pela y corta en cubos.", "Cocina al vapor/horno hasta suave.", "Condimenta y sirve."]
        default:
            return ["Prepara \(food.name) a tu gusto.", "Ajusta condimentos y sirve."]
        }
    }
}

// Secciones del picker
private enum DetailSection: Hashable {
    case ingredientes
    case receta
}

// MARK: - Componentes de estilo

private struct ModernGroupBoxStyle: GroupBoxStyle {
    var accent: Color
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                configuration.label
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.bottom, 2)

            configuration.content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(accent.opacity(0.15), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

private struct EmptyStateView: View {
    var title: String
    var subtitle: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "tray")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

private struct CalorieProgress: View {
    var calories: Int
    private let goal: Double = 600 // meta visual de referencia

    var body: some View {
        let progress = min(Double(calories) / goal, 1.0)
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .leading) {
                Capsule().fill(Color.primary.opacity(0.08))
                    .frame(height: 8)
                Capsule().fill(Color.green)
                    .frame(width: max(8, progressWidth(progress: progress)), height: 8)
            }
            .animation(.spring(duration: 0.35, bounce: 0.2), value: calories)
            Text("Meta visual: \(Int(goal)) kcal")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func progressWidth(progress: Double) -> CGFloat {
        // Este valor será reemplazado por el layout real del contenedor en runtime; usamos un mínimo para animación
        // En ejecución real, SwiftUI ajusta el ancho con GeometryReader si fuera necesario.
        return CGFloat(progress) * 160
    }
}

#Preview {
    NavigationStack {
        FoodDetailView(
            food: Food(id: UUID(), name: "Frijoles", calories: 140, category: "Leguminosa", ingredients: nil, steps: nil),
            mealType: .lunch
        )
    }
}

