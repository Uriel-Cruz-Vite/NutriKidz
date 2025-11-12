//
//  SummaryStepView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 28/10/25.
//

import SwiftUI

struct SummaryStepView: View {
    let name: String
    let age: Int
    let sex: String
    let weight: Double
    let height: Double

    let onFinish: () -> Void

    // Cálculo rápido de IMC igual que en UserProfile
    private var bmi: Double {
        guard height > 0 else { return 0 }
        let meters = height / 100.0
        return weight / (meters * meters)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Tu información")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                GroupBox {
                    SummaryRow(label: "Nombre", value: name)
                    Divider()
                    SummaryRow(label: "Edad", value: "\(age) años")
                    Divider()
                    SummaryRow(label: "Sexo", value: sex)
                    Divider()
                    SummaryRow(label: "Peso", value: String(format: "%.1f kg", weight))
                    Divider()
                    SummaryRow(label: "Estatura", value: String(format: "%.1f cm", height))
                    Divider()
                    SummaryRow(label: "IMC (aprox.)", value: String(format: "%.1f", bmi))
                } label: {
                    Label("Perfil", systemImage: "person.fill")
                        .font(.headline)
                }

                Text("Revisa que tus datos sean correctos. Puedes cambiarlos luego en tu Perfil en cualquier momento.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)

                Button {
                    onFinish()
                } label: {
                    Text("Finalizar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.green)
                        )
                        .foregroundColor(.white)
                }
            }
            .padding()
            .padding(.top, 40)
        }
        .navigationBarBackButtonHidden(true)
    }
}

// Fila visual simple para el resumen
struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body.weight(.medium))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        SummaryStepView(
            name: "Alex",
            age: 12,
            sex: "Masculino",
            weight: 42.5,
            height: 150.0,
            onFinish: { /* no-op for preview */ }
        )
    }
    .padding()
}
