//
//  LargeMusicItemBlock.swift
//  Resonance
//
//  Created by Russal Arya on 24/9/2025.
//

import SwiftUI
import MusicKit

struct LargeMusicItemBlock: View {
    let artwork: Artwork?
    let title: String
    let artistName: String?
    let playCount: Int?
    let size: CGFloat
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                ArtworkView(artwork: artwork, width: size, height: size, cornerRadius: 6)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.customPurple)
                        .lineLimit(1)
                        .frame(width: size, alignment: .leading)
                    
                    if (artistName != nil) {
                        Text(artistName ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.customLightPurple)
                            .lineLimit(1)
                            .frame(width: size, alignment: .leading)
                    }
                }

                if let plays = playCount {
                    Text(plays.formatted() + " plays")
                        .font(.system(size: 14))
                        .foregroundColor(.customLightPurple)
                        .lineLimit(1)
                }
            }
        }
        .padding(.bottom, 16)
        .buttonStyle(.plain) // removes SwiftUI’s default button tint
    }
}
