//
//  DesingSystem.swift
//  Nutricion
//
//  Created by Uriel Cruz on 28/10/25.
//

import SwiftUI

/// Design System global para la app.
/// Usa `DS.Spacing`, `DS.Radius`, `DS.Fonts` y componentes como `DS.Card` o `DS.PrimaryButton`.
enum DS {

    // MARK: - Tokens
    enum Spacing {
        static let xs: CGFloat = 4
        static let s:  CGFloat = 8
        static let m:  CGFloat = 12
        static let l:  CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Radius {
        static let small: CGFloat = 10
        static let card:  CGFloat = 16
        static let pill:  CGFloat = 24
    }

    enum Fonts {
        // Usa SF por defecto; ajusta tamaños si quieres un look distinto
        static let title   = Font.system(.title2, design: .rounded).weight(.semibold)
        static let heading = Font.system(.headline, design: .rounded)
        static let body    = Font.system(.body, design: .rounded)
        static let caption = Font.system(.caption, design: .rounded)
        static let mono    = Font.system(.footnote, design: .monospaced)
    }

    /// Paleta semántica para respetar Light/Dark automáticamente.
    enum Palette {
        static let bgCard   = Color(.secondarySystemBackground)
        static let border   = Color.secondary.opacity(0.15)
        static let accent   = Color.accentColor
        static let positive = Color.green
        static let warning  = Color.orange
        static let danger   = Color.red
        static let textMuted = Color.secondary
    }

    // MARK: - Componentes

    /// Contenedor visual con fondo y sombra suave para agrupar contenido.
    struct Card<Content: View>: View {
        let content: Content
        var padding: CGFloat
        var cornerRadius: CGFloat

        init(padding: CGFloat = Spacing.l,
             cornerRadius: CGFloat = Radius.card,
             @ViewBuilder content: () -> Content) {
            self.padding = padding
            self.cornerRadius = cornerRadius
            self.content = content()
        }

        var body: some View {
            content
                .padding(padding)
                .background(Palette.bgCard, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Palette.border, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
    }

    /// Botón principal de acción con estilo consistente.
    struct PrimaryButton: View {
        let title: String
        let action: () -> Void
        var disabled: Bool = false

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(Fonts.heading)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.m)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(disabled ? Palette.accent.opacity(0.35) : Palette.accent,
                        in: RoundedRectangle(cornerRadius: Radius.pill, style: .continuous))
            .foregroundStyle(.white)
            .opacity(disabled ? 0.8 : 1.0)
            .accessibilityLabel(Text(title))
            .disabled(disabled)
        }
    }

    /// Botón secundario para acciones no primarias.
    struct SecondaryButton: View {
        let title: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(Fonts.body)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.m)
            }
            .buttonStyle(.plain)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Radius.pill, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.pill, style: .continuous)
                    .stroke(Palette.border, lineWidth: 1)
            )
            .foregroundStyle(.primary)
            .accessibilityLabel(Text(title))
        }
    }

    /// Etiqueta tipo “chip/tag” para mostrar categorías o pequeñas métricas.
    struct Tag: View {
        let text: String
        var icon: String? = nil
        var tint: Color = Palette.bgCard

        var body: some View {
            HStack(spacing: Spacing.s) {
                if let icon { Image(systemName: icon).font(.caption) }
                Text(text).font(Fonts.caption).lineLimit(1)
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.xs)
            .background(tint.opacity(0.5), in: Capsule())
            .overlay(Capsule().stroke(Palette.border, lineWidth: 1))
            .foregroundStyle(.primary)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(text))
        }
    }

    /// Encabezado de sección con subtítulo opcional.
    struct SectionHeader: View {
        let title: String
        var subtitle: String? = nil
        var icon: String? = nil

        var body: some View {
            HStack(spacing: Spacing.s) {
                if let icon { Image(systemName: icon).font(.headline) }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(Fonts.heading)
                    if let subtitle {
                        Text(subtitle).font(Fonts.caption).foregroundStyle(Palette.textMuted)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, Spacing.s)
        }
    }

    // MARK: - Helpers

    /// Separador sutil para listas personalizadas.
    static var divider: some View {
        Divider().overlay(Palette.border)
    }
}

// MARK: - Previews
#Preview("Design System — Components") {
    ScrollView {
        VStack(alignment: .leading, spacing: DS.Spacing.xl) {

            DS.SectionHeader(title: "Botones", subtitle: "Primario y Secundario", icon: "square.stack.3d.up")
            DS.PrimaryButton(title: "Continuar", action: {})
            DS.SecondaryButton(title: "Cancelar", action: {})

            DS.SectionHeader(title: "Card", subtitle: "Contenedor", icon: "rectangle.roundedbottom")
            DS.Card {
                VStack(alignment: .leading, spacing: DS.Spacing.s) {
                    Text("Título de tarjeta").font(DS.Fonts.title)
                    Text("Descripción breve para demostrar el estilo de tarjeta.").foregroundStyle(DS.Palette.textMuted)
                    HStack {
                        DS.Tag(text: "Alto en proteína", icon: "bolt.fill")
                        DS.Tag(text: "Sin gluten")
                    }
                }
            }

            DS.SectionHeader(title: "Tags", icon: "tag")
            HStack {
                DS.Tag(text: "Kcal 520", icon: "flame.fill")
                DS.Tag(text: "P 35g")
                DS.Tag(text: "C 60g")
                DS.Tag(text: "G 12g")
            }
        }
        .padding()
    }
}
