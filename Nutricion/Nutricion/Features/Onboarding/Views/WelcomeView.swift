//
//  WelcomeView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 28/10/25.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("didSeeWelcome") private var didSeeWelcome: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemGreen).opacity(0.4),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                // Encabezado / branding
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 88, height: 88)
                            .shadow(color: .black.opacity(0.1), radius: 12, y: 6)

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.green)
                    }

                    Text("Nutrición")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundColor(.primary)

                    Text("Te ayudamos a construir hábitos sanos paso a paso.")
                        .font(.system(.body, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 20)

                // Lista de beneficios (usa FeatureRow reutilizable)
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(
                        icon: "list.bullet.rectangle.portrait.fill",
                        title: "Plan semanal inteligente",
                        detail: "Ideas de comida para cada día."
                    )

                    FeatureRow(
                        icon: "heart.circle.fill",
                        title: "Enfocado en tu salud",
                        detail: "Usa tu edad, peso y estatura para cuidarte mejor."
                    )

                    FeatureRow(
                        icon: "checkmark.seal.fill",
                        title: "Pensado para familias",
                        detail: "Claro, rápido y fácil de seguir."
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

                Spacer()

                // Botón continuar
                Button {
                    didSeeWelcome = true
                } label: {
                    Text("Continuar")
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.green)
                                .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: 500)
        }
    }
}

#Preview {
    WelcomeView()
}
