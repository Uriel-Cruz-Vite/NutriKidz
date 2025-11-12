//
//  NutricionApp.swift
//  Nutricion
//
//  Created by Uriel Cruz on 27/10/25.
//

import SwiftUI

@main
struct NutricionApp: App {
    @AppStorage("didSeeWelcome") private var didSeeWelcome: Bool = false
    @AppStorage("didOnboard") private var didOnboard: Bool = false
    var body: some Scene {
        WindowGroup {
            if !didSeeWelcome {
                // Paso 1: Bienvenida
                WelcomeView()
            } else if !didOnboard {
                // Paso 2: Capturar datos del perfil
                OnboardingFlowView()
            } else {
                // Paso 3: App normal
                ContentView()
            }
        }
    }
}
