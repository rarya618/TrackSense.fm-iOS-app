//
//  AlbumTrack.swift
//  Resonate
//
//  Created by Russal Arya on 23/9/2025.
//

import SwiftUI
import MusicKit

struct TrackRow: View {
    let track: Track
    var adjustedArtworkColor: Color
    let showArtwork: Bool
    let onTap: () -> Void

    private var artworkColor: Color {
        if let cgColor = track.artwork?.backgroundColor {
            return Color(cgColor)
        } else {
            return Color.landingPurple
        }
    }
    
    private var primaryColor: Color {
        if let cgColor = track.artwork?.primaryTextColor {
            return Color(cgColor)
        } else {
            return .buttonLabelColor
        }
    }
    
    var body: some View {
        if showArtwork {
            MusicItemBlock(
                artwork: track.artwork,
                title: track.title,
                artistName: track.artistName,
                playCount: track.playCount,
                removeSpacer: false,
                removeEllipsis: false
            ) {
                onTap()
            }
        } else {
            NavigationLink(destination: TrackView(track: track)) {
                HStack(spacing: 14) {
                    // Rank badge
                    ZStack {
                        LinearGradient(
                            colors: [adjustedArtworkColor, adjustedArtworkColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(Capsule())
                        
                        
                        if let trackNumber = track.trackNumber {
                            Text("\(trackNumber.description)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.resonateWhite)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                        }
                    }
                    .frame(minWidth: 32)
                    .fixedSize() // prevents unwanted stretching
                    
                    HStack {
                        VStack(spacing: 2) {
                            Text(track.title)
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .foregroundColor(adjustedArtworkColor)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack (spacing: 6) {
                                Text(track.artistName)
                                    .font(.system(size: 14))
                                    .foregroundColor(adjustedArtworkColor.opacity(0.8))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1)
                                
                                if let playCount = track.playCount {
                                    Circle()
                                        .fill(adjustedArtworkColor.opacity(0.4))
                                        .frame(width: 3, height: 3)
                                    
                                    Text(playCount.formatted() + " plays")
                                        .font(.system(size: 14))
                                        .foregroundColor(adjustedArtworkColor.opacity(0.8))
                                }
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 14)
                        
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                        }
                        .fontWeight(.bold)
                        .font(Font.system(size: 24))
                        .foregroundColor(adjustedArtworkColor)
                    }
                }
                .padding(.horizontal, 16)
            }
            .background(adjustedArtworkColor.opacity(0.12))
            .cornerRadius(8)
            .contentShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

extension UIColor {
    var luminance: CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)

        func adjust(_ v: CGFloat) -> CGFloat {
            return (v < 0.03928) ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * adjust(r) + 0.7152 * adjust(g) + 0.0722 * adjust(b)
    }

    func contrastRatio(with other: UIColor) -> CGFloat {
        let l1 = luminance
        let l2 = other.luminance
        return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)
    }
}
