//
//  SongStatsView.swift
//  Resonate
//
//  Created by Russal Arya on 22/9/2025.
//

import SwiftUI
import MusicKit

struct SongStatsView: View {
    let song: Song
    
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                if let playCount = song.playCount {
                    StatContainerView(title: "Plays", value: playCount.formatted())
                    
                    if let duration = song.duration {
                        let totalMinutes = getMinutesPlayed(playCount: playCount, duration: duration)
                        StatContainerView(title: "Minutes", value: Int(totalMinutes).formatted())
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            if let lastPlayed = song.lastPlayedDate {
                StatContainerView(title: "Last played", value: lastPlayed.formatted())
            }
            
            if let discoveredDate = song.libraryAddedDate {
                StatContainerView(title: "Discovered", value: discoveredDate.formatted())
            }
            
            if let releaseDate = song.releaseDate {
                StatContainerView(title: "Release date", value: releaseDate.formatted())
            }
            
            if let trackNumber = song.trackNumber {
                StatContainerView(title: "Track number", value: trackNumber.formatted())
            }
        }
        .frame(maxWidth: .infinity)
    }
}

func getMinutesPlayed (playCount: Int, duration: Double) -> Double {
    return (Double(playCount) * duration) / 60
}
