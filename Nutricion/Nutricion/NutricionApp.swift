//
//  NutricionApp.swift
//  Nutricion
//
//  Created by Uriel Cruz on 27/10/25.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct NutricionApp: App {
    @AppStorage("didSeeWelcome") private var didSeeWelcome: Bool = false
    @AppStorage("didOnboard") private var didOnboard: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            rootView()
                .environmentObject(auth)
        }
    }

    @ViewBuilder
    private func rootView() -> some View {
        if !didSeeWelcome {
            WelcomeView()
        } else if auth.user == nil {
            LoginView()
        } else if !didOnboard {
            OnboardingFlowView()
        } else {
            ContentView()
        }
    }
}

