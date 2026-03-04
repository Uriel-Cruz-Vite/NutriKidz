//
//  AuthViewModel.swift
//  Nutricion
//
//  Created by Uriel Cruz on 18/12/25.
//

import Foundation
import SwiftUI
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseAnalytics

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        // Verifica que Firebase esté configurado
        if FirebaseApp.app() == nil {
            assertionFailure("FirebaseApp.configure() no se ejecutó. Revisa AppDelegate y GoogleService-Info.plist.")
        }

        // Escucha cambios de sesión
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
            }
        }
        // Estado inicial
        self.user = Auth.auth().currentUser
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    // MARK: - Email/Password
    func signIn(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user

            // Analytics: set userID y evento de login exitoso
            Analytics.setUserID(result.user.uid)
            Analytics.logEvent("login_success", parameters: [
                "provider": "password"
            ])
        } catch {
            handleAuthError(error)
        }
        isLoading = false
    }

    func signUp(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user

            // Analytics: set userID y evento de registro exitoso
            Analytics.setUserID(result.user.uid)
            Analytics.logEvent("signup_success", parameters: [
                "provider": "password"
            ])
        } catch {
            handleAuthError(error)
        }
        isLoading = false
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil

            // Analytics: evento de logout y limpiar userID
            Analytics.logEvent("logout", parameters: nil)
            Analytics.setUserID(nil)
        } catch {
            handleAuthError(error)
        }
    }

    // MARK: - Placeholders para Apple / Google (futuro)
    func signInWithApple() async {
        errorMessage = "Sign in with Apple aún no está implementado."
        Analytics.logEvent("auth_provider_unimplemented", parameters: [
            "provider": "apple"
        ])
    }

    func signInWithGoogle() async {
        errorMessage = "Sign in with Google aún no está implementado."
        Analytics.logEvent("auth_provider_unimplemented", parameters: [
            "provider": "google"
        ])
    }

    // MARK: - Debug y mapeo de errores
    private func handleAuthError(_ error: Error) {
        let ns = error as NSError
        // Logs detallados en consola
        print("Auth error:")
        print("  domain: \(ns.domain)")
        print("  code: \(ns.code)")
        print("  userInfo: \(ns.userInfo)")

        // Analytics: evento genérico de error de auth
        Analytics.logEvent("auth_error", parameters: [
            "code": ns.code as NSNumber,
            "domain": ns.domain
        ])

        if let code = AuthErrorCode(rawValue: ns.code) {
            switch code {
            case .networkError:
                errorMessage = "Problema de red. Verifica tu conexión a Internet."
            case .invalidEmail:
                errorMessage = "El correo no es válido."
            case .userDisabled:
                errorMessage = "La cuenta está deshabilitada."
            case .wrongPassword:
                errorMessage = "Contraseña incorrecta."
            case .emailAlreadyInUse:
                errorMessage = "Ese correo ya está en uso."
            case .operationNotAllowed:
                errorMessage = "Proveedor no permitido. Habilita Email/Password en Firebase Console."
            case .internalError:
                errorMessage = "Error interno de Firebase. Revisa configuración de GoogleService-Info.plist y API Key."
                // Analytics: evento específico para internalError con una pista/hint
                Analytics.logEvent("auth_internal_error", parameters: [
                    "hint": "check_plist_and_api_key"
                ])
            default:
                errorMessage = ns.localizedDescription
            }
        } else {
            errorMessage = ns.localizedDescription
        }
    }
}
