//
//  ArtistDetailsView.swift
//  Resonate
//
//  Created by Russal Arya on 24/9/2025.
//

import SwiftUI
import MusicKit

struct ArtistDetailsView: View {
    let artist: Artist
    let artwork: Artwork?
    let name: String
    let text: String?
    let playSong: () -> Void

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
            VStack(spacing: 28) {
                VStack(alignment: .center, spacing: 10) {
                    ArtworkView(
                        artwork: artwork,
                        width: 96,
                        height: 96,
                        cornerRadius: .infinity
                    )

                    Text(name)
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(nil) // allow wrapping if needed
                        .foregroundStyle(primaryColor)
                        .multilineTextAlignment(.center)
                    
                }
                .padding(.horizontal, 0)
                .padding(.vertical, 0)

//                MusicItemButtons (
//                    musicItem: artist,
//                    playMusicItem: {playSong()},
//                    duration: nil,
//                    albumTitle: nil,
//                    artworkColor: artworkColor,
//                    primaryColor: primaryColor,
//                    betterTextColor: betterTextColor,
//                    menuItems: []
//                )
            }
            .padding(.horizontal, 22)
            .padding(.top, 112)
            .padding(.bottom, 12)
        }
    }
}
