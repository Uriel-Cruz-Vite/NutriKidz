//
//  OnboardingViewModel.swift
//  Nutricion
//
//  Created by Uriel Cruz on 28/10/25.
//

import SwiftUI
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {

    // Campos que vamos llenando paso a paso
    @Published var name: String = ""
    @Published var age: Int = 10
    @Published var sex: String = "Masculino"
    @Published var weight: Double = 0.0  // kg
    @Published var height: Double = 0.0  // cm

    // Para guardar el perfil en UserDefaults igual que ProfileViewModel
    private let key = "UserProfile_v1"

    func saveProfile() {
        let profile = UserProfile(
            name: name,
            age: age,
            sex: sex,
            weight: weight,
            height: height
        )

        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // Opcional: si ya existe perfil guardado, úsalo como valores iniciales
    func loadIfAvailable() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode(UserProfile.self, from: data) else { return }

        self.name = saved.name
        self.age = saved.age
        self.sex = saved.sex
        self.weight = saved.weight
        self.height = saved.height
    }
}

