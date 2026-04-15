//
//  StatRow.swift
//  MusicApp
//
//  Created by Russal Arya on 19/10/2025.
//

import SwiftUI

struct StatRow: View {
    let index: Int
    let title: String
    let subtitle: String?
    let playCount: Int
    let minutesPlayed: Int
    var isShowingPlays = true
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Rank badge
                ZStack {
                    LinearGradient(
                        colors: [.customPurple, .customLightPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(Capsule())
                    
                    Text("\(index)")
                        .font(.montserrat(size: 16, weight: .bold))
                        .foregroundColor(.resonateWhite)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
                .frame(minWidth: 32)
                .fixedSize() // prevents unwanted stretching
                
                // Title & play count
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.montserrat(size: 16, weight: .bold))
                        .tracking(16 * -0.025)
                        .foregroundColor(.customPurple)
                        .lineLimit(1)
                    
                        HStack() {
                            if let subtitle = subtitle {
                                Text(subtitle)
                                    .font(.montserrat(size: 15, weight: .medium))
                                    .tracking(15 * -0.025)
                                    .foregroundColor(.customPurple)
                                    .lineLimit(1)
                                
                                Text("-")
                                    .font(.montserrat(size: 15, weight: .medium))
                                    .tracking(15 * -0.025)
                                    .lineLimit(1)
                            }
                            
                            Text(isShowingPlays ? "\(playCount.formatted()) plays" : "\((minutesPlayed).formatted()) minutes")
                                .font(.montserrat(size: 15, weight: .medium))
                                .foregroundColor(.customLightPurple)
                                .lineLimit(1)
                        }
                    }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.montserrat(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .opacity(0.7)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.resonatePurple.opacity(0.06))
                    .stroke(Color.resonatePurple.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
