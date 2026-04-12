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
    let foregroundColor: Color
    let backgroundColor: Color

    var body: some View {
        Text(text)
            .font(.montserrat(size: 10))
            .fontWeight(.bold)
            .lineLimit(1)
            .foregroundStyle(backgroundColor)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Color.clear)
            .overlay(
                Capsule().stroke(backgroundColor, lineWidth: 1)
            )
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

    private func idealColor (
        textColor: UIColor,
        backgroundColor: UIColor
    ) -> Color {
        let white = UIColor(.resonateWhite)
        
        let backgroundRatio = backgroundColor.contrastRatio(with: white)
        let textRatio = textColor.contrastRatio(with: white)

        if (backgroundRatio > 4.5) {
            return Color(backgroundColor)
        } else if (textRatio > backgroundRatio) {
            return Color(textColor)
        } else {
            return Color(backgroundColor)
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
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text(artistName)
                                .font(.montserrat(size: 16, weight: .medium))
                        }
                    
                        if let album = albumTitle {
                            Text(album)
                                .font(.montserrat(size: 14))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        FlowLayout(spacing: 6, rowSpacing: 6) {
                            if isAppleDigitalMaster == true {
                                Pill(
                                    text: "Apple Digital Master",
                                    foregroundColor: artworkColor,
                                    backgroundColor: primaryColor
                                )
                                
                                if let audioVariants = audioVariants {
                                    ForEach(audioVariants.indices, id: \.self) { idx in
                                        let audioVariant = audioVariants[idx]
                                        Pill(
                                            text: convertAudioVariantToText(audioVariant: audioVariant),
                                            foregroundColor: artworkColor,
                                            backgroundColor: primaryColor
                                        )
                                    }
                                }
                            }
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
                    toggleMenu: toggleMenu
                )
            }
            .padding(.horizontal)
            .padding(.top, 110)
            .padding(.bottom, 10)
        }
    }
}

func convertAudioVariantToText(audioVariant: AudioVariant) -> String {
    if (audioVariant.description == ".lossless") {
        return "Lossless"
    } else if (audioVariant.description == ".dolbyAtmos") {
        return "Dolby Atmos"
    } else if (audioVariant.description == ".highResolutionLossless") {
        return "Hi-Res Lossless"
    } else {
        return audioVariant.description
    }
}
