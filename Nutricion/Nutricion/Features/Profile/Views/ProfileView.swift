//
//  ProfileView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 27/10/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var vm = ProfileViewModel()
    @FocusState private var focusedField: Field?
    @State private var showSavedToast = false
    @EnvironmentObject private var auth: AuthViewModel

    private enum Field: Hashable {
        case name, age, weight, height
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.system(size: 44))
                            .foregroundStyle(.tint)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tu perfil")
                                .font(.title2).bold()
                            Text("Completa tu información para obtener recomendaciones precisas")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Personal Info Card
                GroupBox(label: Label("Información personal", systemImage: "info.circle")) {
                    VStack(spacing: 14) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.secondary)
                            TextField("Nombre", text: $vm.profile.name)
                                .textContentType(.name)
                                .submitLabel(.next)
                                .focused($focusedField, equals: .name)
                        }
                        Divider()
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .foregroundStyle(.secondary)
                            HStack {
                                Text("Edad")
                                Spacer()
                                Picker("Edad", selection: $vm.profile.age) {
                                    ForEach(5...18, id: \.self) { age in
                                        Text("\(age)").tag(age)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: 120, alignment: .trailing)
                            }
                        }
                        Divider()
                        HStack(spacing: 12) {
                            Image(systemName: "figure.2.circle")
                                .foregroundStyle(.secondary)
                            Picker("Sexo", selection: $vm.profile.sex) {
                                Text("Masculino").tag("Masculino")
                                Text("Femenino").tag("Femenino")
                            }
                            .pickerStyle(.segmented)
                        }
                        Divider()
                        HStack(spacing: 12) {
                            Image(systemName: "scalemass")
                                .foregroundStyle(.secondary)
                            HStack {
                                Text("Peso (kg)")
                                Spacer()
                                TextField("Ej: 70.5", text: Binding(
                                    get: { vm.profile.weight > 0 ? String(vm.profile.weight) : "" },
                                    set: { vm.profile.weight = Double($0) ?? 0 }
                                ))
                                .keyboardType(.decimalPad)
                                .frame(width: 100)
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .weight)
                            }
                        }
                        Divider()
                        HStack(spacing: 12) {
                            Image(systemName: "ruler")
                                .foregroundStyle(.secondary)
                            HStack {
                                Text("Talla (cm)")
                                Spacer()
                                TextField("Ej: 170", text: Binding(
                                    get: { vm.profile.height > 0 ? String(vm.profile.height) : "" },
                                    set: { vm.profile.height = Double($0) ?? 0 }
                                ))
                                .keyboardType(.decimalPad)
                                .frame(width: 100)
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .height)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal)

                // Results Card
                GroupBox(label: Label("Resultados", systemImage: "chart.bar.xaxis")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("IMC")
                                .font(.headline)
                            Spacer()
                            Text("\(computedBMI, specifier: "%.2f")")
                                .font(.title2).bold()
                                .foregroundStyle(colorForBMI(computedBMI))
                        }

                        ProgressView(value: normalizedBMI(computedBMI)) {
                            Text("Rango saludable 18.5 – 24.9")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tint(colorForBMI(computedBMI))

                        Text(categoryForBMI(computedBMI))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Divider()
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Kcal diarias")
                                    .font(.headline)
                                Spacer()
                                Text("\(vm.profile.dailyCaloriesPractical) kcal")
                                    .font(.title3).bold()
                            }
                            Text("Rango: \(vm.profile.dailyCaloriesRange.min) – \(vm.profile.dailyCaloriesRange.max) kcal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)

                // Actions
                HStack {
                    Button(role: .destructive) {
                        withAnimation { clearForm() }
                    } label: {
                        Label("Limpiar", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button {
                        vm.saveProfile()
                        withAnimation { showSavedToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { showSavedToast = false }
                    } label: {
                        Label("Guardar", systemImage: "tray.and.arrow.down.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
#if os(iOS) || os(tvOS) || os(watchOS)
        .background(Color(.systemGroupedBackground))
#elseif os(macOS)
        .background(Color.windowBackground)
#else
        .background(Color(.secondarySystemBackground))
#endif
        .navigationTitle("Perfil")
        .onAppear { vm.loadProfile() }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Cerrar") { focusedField = nil }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    // Opcional: limpiar datos locales del perfil
                    clearForm()
                    // Cerrar sesión con Firebase
                    auth.signOut()
                } label: {
                    Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .tint(.red)
            }
        }
        .overlay(alignment: .top) {
            if showSavedToast {
                toastView("Perfil guardado")
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
            }
        }
    }

    private var isFormValid: Bool {
        !vm.profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        vm.profile.age > 0 &&
        vm.profile.weight > 0 &&
        vm.profile.height > 0
    }

    private func moveFocusForward() {
        switch focusedField {
        case .name: focusedField = .age
        case .age: focusedField = .weight
        case .weight: focusedField = .height
        case .height: focusedField = nil
        case .none: focusedField = .name
        }
    }

    private func colorForBMI(_ bmi: Double) -> Color {
        // En pediatría usamos la clasificación derivada del peso ideal (temporal)
        switch vm.profile.pediatricDiagnosis {
        case "Desnutrición": return .orange
        case "Peso normal":  return .green
        case "Sobrepeso":    return .yellow
        case "Obesidad":     return .red
        default:              return .gray
        }
    }

    private func normalizedBMI(_ bmi: Double) -> Double {
        // Normalize to 0..1 roughly around 15..35
        let minVal = 15.0
        let maxVal = 35.0
        return min(max((bmi - minVal) / (maxVal - minVal), 0), 1)
    }

    private func categoryForBMI(_ bmi: Double) -> String {
        // Devolver directamente el diagnóstico pediátrico usado en otros cálculos
        let diagnosis = vm.profile.pediatricDiagnosis.trimmingCharacters(in: .whitespacesAndNewlines)
        return diagnosis.isEmpty ? "Sin datos" : diagnosis
    }

    private var computedBMI: Double {
        let hMeters = vm.profile.height / 100
        guard hMeters > 0, vm.profile.weight > 0 else { return 0 }
        return vm.profile.weight / (hMeters * hMeters)
    }

    @ViewBuilder
    private func toastView(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(message)
                .font(.subheadline)
                .bold()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(radius: 3, y: 2)
    }

    private func clearForm() {
        vm.profile.name = ""
        vm.profile.age = 0
        vm.profile.sex = "Masculino"
        vm.profile.weight = 0
        vm.profile.height = 0
    }
}

#Preview {
    NavigationStack { ProfileView() }
}

