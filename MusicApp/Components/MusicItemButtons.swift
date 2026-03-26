//
//  SongButtons.swift
//  Resonate
//
//  Created by Russal Arya on 27/9/2025.
//

import SwiftUI
import MusicKit

struct SongButtons: View {
    let playSong: () -> Void
    let duration: TimeInterval?
    let albumTitle: String?
    var artworkColor: Color
    var primaryColor: Color
    var betterTextColor: Color
    
    var body: some View {
        HStack(spacing: 10) {
            // Play
            Button(action: { playSong() }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Play")
                    if duration != nil {
                        Spacer()
                    }
                    if let receivedDuration = duration {
                        Text(formatTime(receivedDuration))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .fontWeight(.bold)
            .foregroundColor(artworkColor)
            .font(Font.system(size: 16))
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(primaryColor)
            .cornerRadius(.infinity)
            
            // Go to Album
            if albumTitle != nil {
                Button(action: {}) {
                    Image(systemName: "square.stack")
                }
                .fontWeight(.bold)
                .foregroundColor(betterTextColor)
                .font(Font.system(size: 20))
                .frame(maxWidth: 48, maxHeight: 48)
                .glassEffect(.regular.tint(Color.resonateWhite.opacity(0.5)))
            } else {
                Button(action: {}) {
                    Image(systemName: "shuffle")
                    Text("Shuffle")
                }
                .fontWeight(.bold)
                .font(Font.system(size: 16))
                .foregroundColor(betterTextColor)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .glassEffect(.regular.tint(Color.resonateWhite.opacity(0.5)))
            }
            
//            // Share
//            Button(action: {}) {
//                Image(systemName: "square.and.arrow.up")
//            }
//            .fontWeight(.bold)
//            .font(Font.system(size: 20))
//            .frame(maxWidth: 48, maxHeight: 48)
//            .padding(.bottom, 8)
//            .padding(.top, 6)
//            .foregroundStyle(Color.resonatePurple)
//            .background(Color.resonateLightPurple.opacity(0.2))
//            .cornerRadius(.infinity)
            
            // Dots
            Button(action: {}) {
                Image(systemName: "ellipsis")
            }
            .fontWeight(.bold)
            .font(Font.system(size: 28))
            .foregroundColor(betterTextColor)
            .frame(maxWidth: 48, maxHeight: 48)
            .glassEffect(.regular.tint(Color.resonateWhite.opacity(0.5)))
                
//            if song.hasLyrics {
//                Button(action: {}) {
//                    Spacer()
//                    Text("See lyrics")
//                    Spacer()
//                }
//                .fontWeight(.bold)
//                .font(Font.system(size: 16))
//                .padding(.horizontal, 30)
//                .padding(.vertical, 14)
//                .foregroundStyle(artworkColor)
//                .background(primaryColor.opacity(0.3))
//                .cornerRadius(12)
//                .frame(maxWidth: .infinity)
//            }
        }
        .frame(maxWidth: .infinity)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
