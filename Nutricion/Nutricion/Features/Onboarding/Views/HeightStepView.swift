//
//  HeightStepView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 28/10/25.
//

import SwiftUI

struct HeightStepView: View {
    @Binding var height: Double
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text("¿Cuánto mides?")
                .font(.system(.title, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)

            Text("Introduce tu estatura en centímetros.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack {
                TextField("0.0", value: $height, format: .number.precision(.fractionLength(1)))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .focused($focused)

                Text("cm")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 200)
            .padding(.horizontal)

            Spacer()

            NavigationLink(value: OnboardingRoute.summary) {
                Text("Siguiente")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(height <= 0 ? Color.gray.opacity(0.3) : Color.green)
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
            .disabled(height <= 0)
        }
        .padding(.top, 60)
        .onAppear {
            focused = true
        }
    }
}

#Preview {
    NavigationStack {
        HeightStepView(height: .constant(150.0))
    }
}
