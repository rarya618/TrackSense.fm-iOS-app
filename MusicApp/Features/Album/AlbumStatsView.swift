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
                StatContainerView(title: "Plays", value: playCount.formatted())
                
                let totalMinutes = timePlayed / 60
                StatContainerView(title: "Minutes", value: Int(totalMinutes).formatted())
            }
            .frame(maxWidth: .infinity)
            
            StatContainerView(title: "Tracks", value: album.trackCount.formatted())
            
            if let lastPlayed = album.lastPlayedDate {
                StatContainerView(title: "Last played", value: lastPlayed.formatted())
            }
            
            if let discoveredDate = album.libraryAddedDate {
                StatContainerView(title: "Discovered", value: discoveredDate.formatted())
            }
            
            if let releaseDate = album.releaseDate {
                StatContainerView(title: "Release date", value: releaseDate.formatted())
            }
        }
        .frame(maxWidth: .infinity)
    }
}
