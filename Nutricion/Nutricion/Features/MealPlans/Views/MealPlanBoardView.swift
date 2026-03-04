//
//  MealPlanBoardView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 29/10/25.
//

import SwiftUI

struct MealPlanBoardView: View {
    @StateObject private var vm = MealPlanViewModel()
    @StateObject private var profileVM = ProfileViewModel()


    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Tabs de días
                DayTabsView(selected: $vm.selectedDay)
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Encabezado del día
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Resumen")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(titleForSelectedDay(vm.selectedDay))
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                    let total = vm.calories(for: vm.selectedDay)
                    if total > 0 {
                        Label("\(total) kcal", systemImage: "flame.fill")
                            .font(.footnote.weight(.semibold))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(
                                Capsule().fill(.ultraThinMaterial)
                            )
                            .overlay(
                                Capsule().stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)

                // Tarjetas: Desayuno, Comida, Cena
                ScrollView {
                    LazyVStack(spacing: 12, pinnedViews: []) {
                        ForEach(mealsForSelectedDay(vm), id: \.id) { slot in
                            NavigationLink {
                                FoodDetailView(food: slot.food, mealType: slot.type)
                            } label: {
                                MealCardView(slot: slot)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(.thinMaterial)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                                    )
                                    .contentShape(Rectangle())
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .background(
                LinearGradient(colors: [Color.blue.opacity(0.06), Color.purple.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Plan semanal")
            .toolbar {
                // Botón de perfil a la derecha
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Label("Perfil", systemImage: "person.crop.circle")
                    }
                }

                // Barra inferior con opciones principales
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(role: .destructive) {
                        vm.clearPlan()
                    } label: {
                        Label("Limpiar", systemImage: "trash")
                            .font(.body.weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)

                    Spacer()

                    Button {
                        // Usar la meta calórica del perfil para regenerar
                        let target = profileVM.profile.dailyCaloriesPractical
                        vm.generateWeekPlan(targetKcal: target)
                    } label: {
                        Label("Regenerar", systemImage: "arrow.clockwise")
                            .font(.body.weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .onAppear {
            // Cargar perfil y, si tenemos kcal objetivo, regenerar plan acorde
            profileVM.loadProfile()
            let target = profileVM.profile.dailyCaloriesPractical
            if target > 0 {
                vm.generateWeekPlan(targetKcal: target)
            }
        }
    }

    private func titleForSelectedDay(_ day: Weekday) -> String {
        day.fullTitle
    }

    private func mealsForSelectedDay(_ vm: MealPlanViewModel) -> [MealSlot] {
        vm.week.first(where: { $0.day == vm.selectedDay })?.meals
        ?? [
            MealSlot(type: .breakfast, food: nil),
            MealSlot(type: .morningSnack, food: nil),
            MealSlot(type: .lunch, food: nil),
            MealSlot(type: .eveningSnack, food: nil),
            MealSlot(type: .dinner, food: nil)
        ]
    }
}

#Preview {
    MealPlanBoardView()
}

