//
//  LoginView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 18/12/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel

    // Campos
    @State private var email: String = ""
    @State private var password: String = ""

    // Estados UI
    @State private var showPassword: Bool = false
    @State private var showProviderInfo: Bool = false

    @FocusState private var focusedField: Field?
    @State private var currentAction: Action?

    private enum Field: Hashable {
        case email, password
    }

    private enum Action {
        case login
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo degradado sutil
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.15),
                        Color.purple.opacity(0.12),
                        Color.teal.opacity(0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Contenido en tarjeta “glass”
                VStack(spacing: 20) {
                    header

                    formFields

                    primaryActions

                    socialSection

                    if let msg = auth.errorMessage, !msg.isEmpty {
                        errorBanner(msg)
                    }

                    Spacer(minLength: 0)

                    footerNote
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .frame(maxWidth: 520)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 8)
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Próximamente", isPresented: $showProviderInfo) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Apple y Google estarán disponibles más adelante.")
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Cerrar") { focusedField = nil }
                }
            }
            .onAppear { focusedField = .email }
            .onSubmit {
                switch focusedField {
                case .email:
                    focusedField = .password
                case .password:
                    Task { await attemptLogin() }
                case .none:
                    break
                }
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                    Image(systemName: "leaf.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.tint)
                        .font(.system(size: 36))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Bienvenido")
                        .font(.title2.bold())
                    Text("Inicia sesión para continuar")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.top, 8)
        }
    }

    private var formFields: some View {
        VStack(spacing: 14) {
            // Email
            HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                    .foregroundStyle(.secondary)
                TextField("Correo electrónico", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .email)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(borderColorForEmail, lineWidth: 1)
            )

            // Password
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)

                Group {
                    if showPassword {
                        TextField("Contraseña", text: $password)
                    } else {
                        SecureField("Contraseña", text: $password)
                    }
                }
                .textContentType(.password)
                .submitLabel(.go)
                .focused($focusedField, equals: .password)

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { showPassword.toggle() }
                } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(showPassword ? "Ocultar contraseña" : "Mostrar contraseña")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
    }

    private var primaryActions: some View {
        VStack(spacing: 10) {
            // Botón primario: Login
            Button {
                Task { await attemptLogin() }
            } label: {
                HStack {
                    if auth.isLoading && currentAction == .login {
                        ProgressView().tint(.white)
                    }
                    Text("Iniciar sesión")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canSubmit || auth.isLoading)

            // Navegar a "Crear cuenta"
            NavigationLink {
                SignUpView(initialEmail: email)
                    .environmentObject(auth)
            } label: {
                Text("¿No tienes cuenta? Crear cuenta")
                    .font(.footnote)
                    .underline()
                    .foregroundStyle(.tint)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .padding(.top, 4)
    }

    private var socialSection: some View {
        VStack(spacing: 12) {
            HStack {
                Rectangle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(height: 1)
                Text("o continúa con")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Rectangle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(height: 1)
            }
            .padding(.vertical, 4)

            HStack(spacing: 12) {
                Button {
                    showProviderInfo = true
                } label: {
                    Label("Apple", systemImage: "applelogo")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(true)

                Button {
                    showProviderInfo = true
                } label: {
                    Label("Google", systemImage: "globe")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(true)
            }

            Text("Apple/Google disponibles próximamente")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 6)
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.white)
            Text(message)
                .font(.footnote)
                .foregroundStyle(.white)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.red.gradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.red.opacity(0.25), radius: 10, x: 0, y: 6)
        .transition(.move(edge: .top).combined(with: .opacity))
        .padding(.top, 4)
    }

    private var footerNote: some View {
        Text("Al continuar aceptas nuestros Términos y la Política de Privacidad.")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.bottom, 12)
            .padding(.horizontal, 8)
    }

    // MARK: - Helpers

    private var emailTrimmed: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isEmailValid: Bool {
        // Validación razonable de email
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: emailTrimmed)
    }

    private var canSubmit: Bool {
        isEmailValid && password.count >= 6
    }

    private var borderColorForEmail: Color {
        guard !emailTrimmed.isEmpty else { return Color.primary.opacity(0.06) }
        return isEmailValid ? Color.green.opacity(0.4) : Color.red.opacity(0.5)
    }

    private func attemptLogin() async {
        guard canSubmit else { return }
        currentAction = .login
        await auth.signIn(email: emailTrimmed, password: password)
        currentAction = nil
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
