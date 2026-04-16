//
//  DetailsView.swift
//  Resonate
//
//  Created by Russal Arya on 24/9/2025.
//

import SwiftUI
import MusicKit

struct Pill: View {
    let text: String
    let color: Color
    var systemImage: String? = nil

    var body: some View {
        Group {
            if let icon = systemImage {
                Label(text, systemImage: icon)
            } else {
                Text(text)
            }
        }
        .font(.montserrat(size: 12, weight: .medium))
        .tracking(12 * -0.025)
        .lineLimit(1)
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.clear)
        .overlay(Capsule().stroke(color.opacity(0.5), lineWidth: 1))
    }
}

struct DetailsView: View {
    let musicItem: MusicItem
    let artwork: Artwork?
    let title: String
    let artistName: String
    let albumTitle: String?
    let genreNames: [String]
    let playMusicItem: () -> Void
    let duration: TimeInterval?
    let isAppleDigitalMaster: Bool?
    let audioVariants: [AudioVariant]?
    var menuItems: [[MenuItem]] = []
    var toggleMenu: () -> Void = {}
    var goToAlbum: (() -> Void)? = nil

    private let topContentInset: CGFloat = 110

    private var artworkColor: Color {
        if let cgColor = artwork?.backgroundColor {
            return Color(cgColor)
        } else {
            return Color.landingPurple
        }
    }
    
    private var primaryColor: Color {
        if let cgColor = artwork?.primaryTextColor {
            return Color(cgColor)
        } else {
            return .white
        }
    }

    private var betterTextColor: Color {
        if let textCG = artwork?.primaryTextColor,
            let bgCG = artwork?.backgroundColor {
                let textColor = UIColor(cgColor: textCG)
                let bgColor = UIColor(cgColor: bgCG)
                return idealColor(textColor: textColor, backgroundColor: bgColor)
        }
        return .resonatePurple
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background derived from artwork
            artworkColor
                .ignoresSafeArea()

            VStack(spacing: 28) {
                HStack(alignment: .top, spacing: 16) {
                    ArtworkView(
                        artwork: artwork,
                        width: 80,
                        height: 80,
                        cornerRadius: 12
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.resonateWhite.opacity(0.25), lineWidth: 1)
                    )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Title + artist grouped
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.montserrat(size: 20, weight: .bold))
                                .tracking(20 * -0.025)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(artistName)
                                .font(.montserrat(size: 16, weight: .medium))
                                .tracking(16 * -0.025)
                        }

                        if let album = albumTitle {
                            Label(album, systemImage: "square.stack")
                                .font(.montserrat(size: 13))
                                .tracking(13 * -0.025)
                                .opacity(0.75)
                        }
                    }
                    .foregroundStyle(primaryColor)
                    .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.vertical, 8)

                MusicItemButtons (
                    musicItem: musicItem,
                    playMusicItem: {playMusicItem()},
                    duration: duration,
                    albumTitle: albumTitle,
                    artworkColor: artworkColor,
                    primaryColor: primaryColor,
                    betterTextColor: betterTextColor,
                    menuItems: menuItems,
                    toggleMenu: toggleMenu,
                    goToAlbum: goToAlbum
                )
            }
            .padding(.horizontal)
            .padding(.top, topContentInset)
            .padding(.bottom, 10)
        }
    }
}

extension AudioVariant {
    var displayName: String {
        switch description {
        case ".lossless": return "Lossless"
        case ".dolbyAtmos": return "Dolby Atmos"
        case ".highResolutionLossless": return "Hi-Res Lossless"
        default: return description
        }
    }

    var displayIcon: String {
        switch description {
        case ".lossless": return "waveform"
        case ".dolbyAtmos": return "dot.radiowaves.left.and.right"
        case ".highResolutionLossless": return "waveform.badge.magnifyingglass"
        default: return "waveform"
        }
    }
}
