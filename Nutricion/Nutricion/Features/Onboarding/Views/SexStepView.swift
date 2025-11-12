//
//  SexStepView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 28/10/25.
//

import SwiftUI

struct SexStepView: View {
    @Binding var sex: String
    let options = ["Masculino", "Femenino"]

    var body: some View {
        VStack(spacing: 24) {
            Text("¿Cuál es tu sexo?")
                .font(.system(.title, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)

            Text("Esto se usa en algunas referencias nutricionales.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Picker("Sexo", selection: $sex) {
                ForEach(options, id: \.self) { opt in
                    Text(opt).tag(opt)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Spacer()

            NavigationLink(value: OnboardingRoute.weight) {
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
        SexStepView(sex: .constant("Femenino"))
    }
}
