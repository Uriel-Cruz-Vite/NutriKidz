//
//  WeightStepView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 28/10/25.
//

import SwiftUI

struct WeightStepView: View {
    @Binding var weight: Double
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text("¿Cuánto pesas?")
                .font(.system(.title, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)

            Text("Introduce tu peso actual en kilogramos.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack {
                TextField("0.0", value: $weight, format: .number.precision(.fractionLength(1)))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .focused($focused)

                Text("kg")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 200)
            .padding(.horizontal)

            Spacer()

            NavigationLink(value: OnboardingRoute.height) {
                Text("Siguiente")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(weight <= 0 ? Color.gray.opacity(0.3) : Color.green)
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
            .disabled(weight <= 0)
        }
        .padding(.top, 60)
        .onAppear {
            focused = true
        }
    }
}

#Preview {
    NavigationStack {
        WeightStepView(weight: .constant(42.5))
    }
}
