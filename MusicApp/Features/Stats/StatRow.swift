//
//  StatRow.swift
//  MusicApp
//
//  Created by Russal Arya on 19/10/2025.
//


struct StatRow: View {
    let index: Int
    let title: String
    let playCount: Int
    let minutesPlayed: Int
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
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    
                    Text("\(index)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.resonateWhite)
                }
                
                // Title & play count
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.customPurple)
                        .lineLimit(1)
                    
                    Text("\(playCount.formatted()) plays - \((minutesPlayed).formatted()) minutes")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.customLightPurple)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .opacity(0.7)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contentShape(Rectangle())
            .hoverEffect(.highlight)
        }
        .buttonStyle(.plain)
    }
}
