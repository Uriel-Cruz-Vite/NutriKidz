//
//  DayTabsView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 29/10/25.
//

import SwiftUI

struct DayTabsView: View {
    @Binding var selected: Weekday

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Weekday.allCases) { day in
                    Button {
                        selected = day
                    } label: {
                        Text(day.shortTitle)
                            .font(.subheadline.weight(.semibold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(day == selected ? Color.green.opacity(0.2) : Color.secondary.opacity(0.12))
                            )
                            .overlay(
                                Capsule().stroke(day == selected ? Color.green : Color.clear, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 4)
        }
    }
}

#Preview {
    struct Host: View {
        @State var day: Weekday = .monday
        var body: some View { DayTabsView(selected: $day) }
    }
    return Host()
}
