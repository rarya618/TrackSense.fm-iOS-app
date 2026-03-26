//
//  AlbumStatsView.swift
//  Resonate
//
//  Created by Russal Arya on 23/9/2025.
//

import SwiftUI
import MusicKit

struct PlaylistStatsView: View {
    let playlist: Playlist
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
            
            if let lastPlayed = playlist.lastPlayedDate {
                StatContainerView(title: "Last played", value: lastPlayed.formatted())
            }
            
            if let lastModifiedDate = playlist.lastModifiedDate {
                StatContainerView(title: "Last modified", value: lastModifiedDate.formatted())
            }
            
            if let libraryAddedDate = playlist.libraryAddedDate {
                StatContainerView(title: "Added to library", value: libraryAddedDate.formatted())
            }
        }
        .frame(maxWidth: .infinity)
    }
}
