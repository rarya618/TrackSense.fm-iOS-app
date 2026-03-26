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
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.resonateWhite)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
                .frame(minWidth: 32)
                .fixedSize() // prevents unwanted stretching
                
                // Title & play count
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.customPurple)
                        .lineLimit(1)
                    
                        HStack() {
                            if let subtitle = subtitle {
                                Text(subtitle)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.customPurple)
                                    .lineLimit(1)
                                
                                Text("-")
                                    .font(.system(size: 15, weight: .medium))
                                    .lineLimit(1)
                            }
                            
                            Text(isShowingPlays ? "\(playCount.formatted()) plays" : "\((minutesPlayed).formatted()) minutes")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.customLightPurple)
                                .lineLimit(1)
                        }
                    }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .opacity(0.7)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.resonatePurple.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
