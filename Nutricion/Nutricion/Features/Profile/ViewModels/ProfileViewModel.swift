//
//  ProfileViewModel.swift
//  Nutricion
//
//  Created by Uriel Cruz on 27/10/25.
//
import SwiftUI
import Combine
import Foundation

final class ProfileViewModel: ObservableObject {
    @Published var profile = UserProfile()

    private let key = "UserProfile_v1"

    // Guardar perfil en UserDefaults
    func saveProfile() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // Cargar perfil desde UserDefaults
    func loadProfile() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode(UserProfile.self, from: data) else { return }
        profile = saved
    }
}
