//
//  AgeStepView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 28/10/25.
//

import SwiftUI

struct AgeStepView: View {
    @Binding var age: Int

    var body: some View {
        VStack(spacing: 24) {
            Text("¿Cuántos años tienes?")
                .font(.system(.title, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)

            Text("Esto nos ayuda a hacer recomendaciones adecuadas para tu etapa de crecimiento.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Picker("Edad", selection: $age) {
                ForEach(5...18, id: \.self) { value in
                    Text("\(value) años").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)

            Spacer()

            NavigationLink(value: OnboardingRoute.sex) {
                Text("Siguiente")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.green)
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
        }
        .padding(.top, 60)
    }
}

#Preview {
    NavigationStack {
        AgeStepView(age: .constant(12))
    }
}
