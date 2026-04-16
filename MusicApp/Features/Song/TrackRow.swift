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
                removeEllipsis: true
            ) {
                onTap()
            }
        } else {
            NavigationLink(destination: SongView(track: track)) {
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
                                .font(.montserrat(size: 16, weight: .bold))
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
                                .font(.montserrat(size: 16))
                                .fontWeight(.bold)
                                .foregroundColor(adjustedArtworkColor)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack (spacing: 6) {
                                Text(track.artistName)
                                    .font(.montserrat(size: 14))
                                    .foregroundColor(adjustedArtworkColor.opacity(0.8))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1)
                                
                                if let playCount = track.playCount {
                                    Circle()
                                        .fill(adjustedArtworkColor.opacity(0.4))
                                        .frame(width: 3, height: 3)
                                    
                                    Text(playCount.formatted() + " plays")
                                        .font(.montserrat(size: 14))
                                        .foregroundColor(adjustedArtworkColor.opacity(0.8))
                                }
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 14)
                        
//                        Button(action: {}) {
//                            Image(systemName: "ellipsis")
//                        }
//                        .fontWeight(.bold)
//                        .font(.montserrat(size: 24))
//                        .foregroundColor(adjustedArtworkColor)
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

