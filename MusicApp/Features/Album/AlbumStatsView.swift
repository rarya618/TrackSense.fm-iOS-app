//
//  AlbumStatsView.swift
//  Resonate
//
//  Created by Russal Arya on 23/9/2025.
//

import SwiftUI
import MusicKit

struct AlbumStatsView: View {
    let album: Album
    
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Stats")
                .fontWeight(.bold)
                .font(.system(size: 24))
            VStack(spacing: 10) {
//                HStack(spacing: 10) {
//                    if let playCount = album.playCount {
//                        StatView(title: "Plays", value: playCount.formatted())
//                        
//                        if let duration = album.duration {
//                            let totalMinutes = (Double(playCount) * duration) / 60
//                            StatView(title: "Minutes", value: Int(totalMinutes).formatted())
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity)
                
                if let lastPlayed = album.lastPlayedDate {
                    StatView(title: "Last played", value: lastPlayed.formatted())
                }
                
                if let discoveredDate = album.libraryAddedDate {
                    StatView(title: "Discovered", value: discoveredDate.formatted())
                }
                
                if let releaseDate = album.releaseDate {
                    StatView(title: "Release date", value: releaseDate.formatted())
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
