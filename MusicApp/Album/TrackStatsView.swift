//
//  SongStatsView.swift
//  MusicApp
//
//  Created by Russal Arya on 22/9/2025.
//

import SwiftUI
import MusicKit

struct TrackStatsView: View {
    let track: Track
    
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Stats")
                .fontWeight(.bold)
                .font(.system(size: 24))
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    if let playCount = track.playCount {
                        StatView(title: "Plays", value: playCount.formatted())
                        
                        if let duration = track.duration {
                            let totalMinutes = (Double(playCount) * duration) / 60
                            StatView(title: "Minutes", value: Int(totalMinutes).formatted())
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                if let lastPlayed = track.lastPlayedDate {
                    StatView(title: "Last played", value: lastPlayed.formatted())
                }
                
                if let discoveredDate = track.libraryAddedDate {
                    StatView(title: "Discovered", value: discoveredDate.formatted())
                }
                
                if let releaseDate = track.releaseDate {
                    StatView(title: "Release date", value: releaseDate.formatted())
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
