//
//  SongStatsView.swift
//  Resonate
//
//  Created by Russal Arya on 22/9/2025.
//

import SwiftUI
import MusicKit

struct TrackStatsView: View {
    let track: Track
    
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Stats")
                .fontWeight(.bold)
                .font(.montserrat(size: 24))
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    if let playCount = track.playCount {
                        StatContainerView(title: "Plays", value: playCount.formatted())
                        
                        if let duration = track.duration {
                            let totalMinutes = (Double(playCount) * duration) / 60
                            StatContainerView(title: "Minutes", value: Int(totalMinutes).formatted())
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                if let lastPlayed = track.lastPlayedDate {
                    StatContainerView(title: "Last played", value: lastPlayed.formatted())
                }
                
                if let discoveredDate = track.libraryAddedDate {
                    StatContainerView(title: "Discovered", value: discoveredDate.formatted())
                }
                
                if let releaseDate = track.releaseDate {
                    StatContainerView(title: "Release date", value: releaseDate.formatted())
                }
                
                if let trackNumber = track.trackNumber {
                    StatContainerView(title: "Track number", value: trackNumber.formatted())
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
