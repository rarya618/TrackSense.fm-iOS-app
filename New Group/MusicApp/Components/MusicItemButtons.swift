//
//  SongButtons.swift
//  Resonate
//
//  Created by Russal Arya on 27/9/2025.
//

import SwiftUI
import MusicKit

struct MusicItemButtons: View {
    let musicItem: MusicItem
    let playMusicItem: () -> Void
    let duration: TimeInterval?
    let albumTitle: String?
    let artworkColor: Color
    let primaryColor: Color
    let betterTextColor: Color
    let menuItems: [[MenuItem]]
    var toggleMenu: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 10) {
            // Play
            Button(action: { playMusicItem() }) {
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
            
//            // NEED TO IMPLEMENT [VERSION 1.1]
//            // Go to Album
//            if albumTitle != nil {
//                Button(action: {}) {
//                    Image(systemName: "square.stack")
//                }
//                .fontWeight(.bold)
//                .foregroundColor(betterTextColor)
//                .font(Font.system(size: 20))
//                .frame(maxWidth: 48, maxHeight: 48)
//                .glassEffect(.regular.tint(Color.resonateWhite.opacity(0.5)))
//            } else {
//                Button(action: {}) {
//                    Image(systemName: "shuffle")
//                    Text("Shuffle")
//                }
//                .fontWeight(.bold)
//                .font(Font.system(size: 16))
//                .foregroundColor(betterTextColor)
//                .padding(.horizontal, 24)
//                .padding(.vertical, 14)
//                .frame(maxWidth: .infinity)
//                .glassEffect(.regular.tint(Color.resonateWhite.opacity(0.5)))
//            }
            
            Button(action: toggleMenu) {
                Image(systemName: "ellipsis")
            }
            .fontWeight(.bold)
            .font(Font.system(size: 28))
            .foregroundColor(betterTextColor)
            .frame(maxWidth: 48, maxHeight: 48)
            .glassEffect(.regular.tint(Color.resonateWhite.opacity(0.5)))
            
//            Menu {
//                generateMenu(menuItems)
//            } label: {
//                Image(systemName: "ellipsis")
//                    .fontWeight(.bold)
//                    .font(Font.system(size: 28))
//                    .foregroundColor(betterTextColor)
//                    .frame(maxWidth: 48, maxHeight: 48)
//                    .glassEffect(.regular.tint(Color.resonateWhite.opacity(0.5)))
//            }
                
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
