//
//  NameStepView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 28/10/25.
//

import SwiftUI

struct NameStepView: View {
    @Binding var name: String
    @FocusState private var focused: Bool
    @State private var pathTrigger: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Text("¿Cómo te llamas?")
                .font(.system(.title, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)

            Text("Usaremos tu nombre para personalizar tu plan.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            TextField("Tu nombre", text: $name)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .padding(.horizontal)
                .keyboardType(.default)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .focused($focused)

            Spacer()

            NavigationLink(value: OnboardingRoute.age) {
                Text("Siguiente")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.3) : Color.green)
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.top, 60)
        .onAppear {
            focused = true
        }
    }
}
