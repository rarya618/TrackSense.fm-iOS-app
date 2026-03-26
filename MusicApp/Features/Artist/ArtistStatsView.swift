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
    var playCount: Int
    var timePlayed: Double
    
    @State private var errorMessage: String?
    @State private var tracks: MusicItemCollection<Track> = []
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                StatView(title: "Plays", value: playCount.formatted())
                
                let totalMinutes = timePlayed / 60
                StatView(title: "Minutes", value: Int(totalMinutes).formatted())
            }
            .frame(maxWidth: .infinity)
            
            StatView(title: "Tracks", value: album.trackCount.formatted())
            
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
        .frame(maxWidth: .infinity)
    }
}
