//
//  StatContainerView.swift
//  Resonate
//
//  Created by Russal Arya on 21/9/2025.
//

import SwiftUI
import MusicKit

struct StatDelta {
    enum Direction { case up, down, neutral }

    let label: String
    let direction: Direction

    var color: Color {
        switch direction {
        case .up:      return .green
        case .down:    return .red
        case .neutral: return .secondary
        }
    }

    var icon: String {
        switch direction {
        case .up:      return "arrow.up"
        case .down:    return "arrow.down"
        case .neutral: return "minus"
        }
    }
}

struct StatContainerView: View {
    let title: String
    let value: String
    var color: Color = .resonatePurple
    var systemImage: String? = nil
    var delta: StatDelta? = nil

    var body: some View {
        ZStack(alignment: .trailing) {
            // Faint background icon
            if let icon = systemImage {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(color.opacity(0.16))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
            }

            // Content
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(value)
                        .font(.montserrat(size: 22, weight: .bold))
                        .tracking(22 * -0.025)
                        .foregroundStyle(.primary)
                    Text(title.lowercased())
                        .font(.montserrat(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)

                    if let delta {
                        Label(delta.label, systemImage: delta.icon)
                            .font(.montserrat(size: 11, weight: .semibold))
                            .foregroundStyle(delta.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(delta.color.opacity(0.12))
                            .clipShape(Capsule())
                            .padding(.top, 4)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.50))
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
