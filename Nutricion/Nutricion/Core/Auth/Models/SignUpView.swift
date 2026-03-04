// SignUpView.swift
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    // Campos
    @State private var email: String
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    // Estados UI
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var showTerms: Bool = false
    @State private var showPrivacy: Bool = false
    @State private var termsAccepted: Bool = false

    @FocusState private var focusedField: Field?
    @State private var currentActionInSignUp = false

    init(initialEmail: String = "") {
        _email = State(initialValue: initialEmail)
    }

    private enum Field: Hashable {
        case email, password, confirmPassword
    }

    var body: some View {
        ZStack {
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

            VStack(spacing: 20) {
                header

                formFields

                passwordGuidance

                termsView

                primaryActions

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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Label("Atrás", systemImage: "chevron.left")
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Cerrar") { focusedField = nil }
            }
        }
        .sheet(isPresented: $showTerms) {
            InfoSheetView(title: "Términos de servicio", message: "Aquí van los términos de servicio. Sustituye este texto por tus términos reales.")
        }
        .sheet(isPresented: $showPrivacy) {
            InfoSheetView(title: "Política de privacidad", message: "Aquí va tu política de privacidad. Sustituye este texto por tu contenido real.")
        }
        .onAppear { focusedField = .email }
        .onSubmit {
            switch focusedField {
            case .email:
                focusedField = .password
            case .password:
                focusedField = .confirmPassword
            case .confirmPassword:
                Task { await attemptSignup() }
            case .none:
                break
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
                    Text("Crea tu cuenta")
                        .font(.title2.bold())
                    Text("Completa los datos para registrarte")
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
                .submitLabel(.next)
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

            // Confirmación
            HStack(spacing: 12) {
                Image(systemName: "lock.rotation")
                    .foregroundStyle(.secondary)

                Group {
                    if showConfirmPassword {
                        TextField("Confirmar contraseña", text: $confirmPassword)
                    } else {
                        SecureField("Confirmar contraseña", text: $confirmPassword)
                    }
                }
                .textContentType(.password)
                .submitLabel(.go)
                .focused($focusedField, equals: .confirmPassword)

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { showConfirmPassword.toggle() }
                } label: {
                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(showConfirmPassword ? "Ocultar confirmación" : "Mostrar confirmación")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(confirmBorderColor, lineWidth: 1)
            )
        }
    }

    private var passwordGuidance: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Checklist de requisitos
            VStack(alignment: .leading, spacing: 6) {
                requirementRow(isMet: password.count >= 6, text: "Mínimo 6 caracteres")
                requirementRow(isMet: passwordHasLetter, text: "Incluye letras")
                requirementRow(isMet: passwordHasNumber, text: "Incluye números")
            }
            .font(.footnote)

            // Fortaleza de contraseña
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Fortaleza:")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(passwordStrengthLabel)
                        .font(.footnote).bold()
                        .foregroundStyle(passwordStrengthColor)
                }
                ProgressView(value: passwordStrengthProgress)
                    .tint(passwordStrengthColor)
            }
        }
        .padding(.horizontal, 2)
    }

    private func requirementRow(isMet: Bool, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isMet ? .green : .secondary)
            Text(text)
                .foregroundStyle(isMet ? .primary : .secondary)
        }
    }

    private var termsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $termsAccepted) {
                HStack(spacing: 4) {
                    Text("Acepto")
                    Button(action: { showTerms = true }) {
                        Text("Términos")
                            .underline()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.tint)
                    Text("y")
                    Button(action: { showPrivacy = true }) {
                        Text("Política de Privacidad")
                            .underline()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.tint)
                }
            }
            .font(.footnote)
        }
        .padding(.top, 2)
    }

    private var primaryActions: some View {
        VStack(spacing: 10) {
            Button {
                Task { await attemptSignup() }
            } label: {
                HStack {
                    if auth.isLoading && currentActionInSignUp {
                        ProgressView().tint(.white)
                    }
                    Text("Crear cuenta")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canSubmit || auth.isLoading)

            Button {
                dismiss()
            } label: {
                Text("¿Ya tienes cuenta? Inicia sesión")
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
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: emailTrimmed)
    }

    private var passwordHasLetter: Bool {
        password.rangeOfCharacter(from: .letters) != nil
    }

    private var passwordHasNumber: Bool {
        password.rangeOfCharacter(from: .decimalDigits) != nil
    }

    private var passwordsMatch: Bool {
        confirmPassword == password && !confirmPassword.isEmpty
    }

    private var isPasswordValidForSignup: Bool {
        password.count >= 6 && passwordHasLetter && passwordHasNumber
    }

    private var canSubmit: Bool {
        isEmailValid && isPasswordValidForSignup && passwordsMatch && termsAccepted
    }

    private var borderColorForEmail: Color {
        guard !emailTrimmed.isEmpty else { return Color.primary.opacity(0.06) }
        return isEmailValid ? Color.green.opacity(0.4) : Color.red.opacity(0.5)
    }

    private var confirmBorderColor: Color {
        guard !confirmPassword.isEmpty else { return Color.primary.opacity(0.06) }
        return passwordsMatch ? Color.green.opacity(0.4) : Color.red.opacity(0.5)
    }

    private var passwordStrengthScore: Int {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil &&
            password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if passwordHasNumber { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet.punctuationCharacters.union(.symbols)) != nil { score += 1 }
        return score
    }

    private var passwordStrengthProgress: Double {
        Double(passwordStrengthScore) / 4.0
    }

    private var passwordStrengthLabel: String {
        switch passwordStrengthScore {
        case 0...1: return "Débil"
        case 2:     return "Media"
        default:    return "Fuerte"
        }
    }

    private var passwordStrengthColor: Color {
        switch passwordStrengthScore {
        case 0...1: return .red
        case 2:     return .orange
        default:    return .green
        }
    }

    private func attemptSignup() async {
        guard canSubmit else { return }
        currentActionInSignUp = true
        await auth.signUp(email: emailTrimmed, password: password)
        currentActionInSignUp = false
    }
}

// Hoja simple para Términos/Privacidad
private struct InfoSheetView: View {
    let title: String
    let message: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(message)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView(initialEmail: "demo@correo.com")
            .environmentObject(AuthViewModel())
    }
}
