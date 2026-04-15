//
//  BottomBar.swift
//  Resonate
//
//  Created by Russal Arya on 25/9/2025.
//

import SwiftUI
import MusicKit

struct BottomButtonLabel: View {
    var artworkColor: Color
    let icon: String
    let label: String
    var isCustom: Bool = false

    var body: some View {
        Group {
            if isCustom {
                Image(icon)
            } else {
                Image(systemName: icon)
            }
        }
        .accessibilityLabel(label)
        .foregroundStyle(artworkColor)
        .frame(width: 40, height: 40, alignment: .center)
        .cornerRadius(.infinity)
    }
}

// Bottom button
struct BottomButton: View {
    var artworkColor: Color
    let icon: String
    let label: String
    let action: () -> Void
    var isCustom: Bool = false

    var body: some View {
        Button(action: action) {
            BottomButtonLabel(
                artworkColor: artworkColor,
                icon: icon,
                label: label,
                isCustom: isCustom
            )
        }
    }
}

struct BottomBar: View {
    var isStatsVisible: Bool
    var isSessionActive: Bool
    var artworkColor: Color
    var primaryColor: Color
    var currentOutputIcon: String
    var currentOutputName: String
    let toggleStatsVisible: () -> Void
    let togglePlaylistsSheetVisible: () -> Void
    let toggleSession: () -> Void
    let toggleLyrics: () -> Void

    var body: some View {
        // Secondary controls
        HStack {
            BottomButton(
                artworkColor: artworkColor,
                icon: "quote.bubble",
                label: "Lyrics",
                action: {
                    toggleLyrics()
                }
            )
            
            Spacer()

            BottomButton(
                artworkColor: artworkColor,
                icon: "text.badge.plus",
                label: "Add to playlist",
                action: {
                    togglePlaylistsSheetVisible()
                },
            )
            
            Spacer()
            
            DynamicAirPlayButton(
                artworkColor: artworkColor,
                primaryColor: primaryColor
            )
            
            Spacer()

            BottomButton(
                artworkColor: artworkColor,
                icon: "chart.line.uptrend.xyaxis",
                label: "Stats",
                action: {
                    toggleStatsVisible()
                }
            )
            
            Spacer()

            BottomButton(
                artworkColor: isSessionActive ? .red : artworkColor,
                icon: "waveform",
                label: "Session",
                action: {
                    toggleSession()
                }
            )
        }
        .frame(maxWidth: .infinity)
        .font(.montserrat(size: 20))
        .foregroundStyle(artworkColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(primaryColor)
        .cornerRadius(.infinity)
//        .glassEffect(.regular.interactive().tint(primaryColor), in: Capsule())
    }
}

