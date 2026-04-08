//
//  ArtistStatsView.swift
//  Resonate
//
//  Created by Russal Arya on 7/10/2025.
//

import SwiftUI
import MusicKit

func getTotalPlayCountForSongs(_ songs: [Song]) -> Int {
    return songs.reduce(0) { $0 + ($1.playCount ?? 0) }
}

func getTotalTimePlayedForSongs(_ songs: [Song]) -> Double {
    return songs.reduce(0) { total, song in
        if let duration = song.duration {
            return total + Double(song.playCount ?? 0) * duration
        }
        return total
    }
}

struct ArtistStatsView: View {
    let artist: Artist
    var librarySongs: [Song]
    
    @State private var errorMessage: String?

    var playCount: Int { getTotalPlayCountForSongs(librarySongs) }
    var timePlayed: Double { getTotalTimePlayedForSongs(librarySongs) }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                StatContainerView(title: "Plays", value: playCount.formatted())
                
                let totalMinutes = timePlayed / 60
                StatContainerView(title: "Minutes", value: Int(totalMinutes).formatted())
            }
            .frame(maxWidth: .infinity)
            
            StatContainerView(title: "Songs in library", value: librarySongs.count.formatted())
            
            if let discoveredDate = artist.libraryAddedDate {
                StatContainerView(title: "Discovered", value: discoveredDate.formatted())
            }
        }
        .frame(maxWidth: .infinity)
    }
}
