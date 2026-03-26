//
//  FromLibraryView.swift
//  Resonate
//
//  Created by Russal Arya on 5/10/2025.
//

import SwiftUI
import MusicKit

struct FromLibraryView: View {
    var songs: [Song]
    var adjustedArtworkColor: Color
    var errorMessage: String?
    let setSelectedSong: (Song) -> Void
    
    @State private var searchText = ""
    
    var filteredSongs: [Song] {
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.artistName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        if !songs.isEmpty {
            VStack(spacing: 8) {
                InlineSearchBar(searchText: $searchText, label: "Search your library")
                    .padding(.top, 6)
                    .padding(.bottom, 12)
                
                LazyVStack(spacing: 8) {
                    ForEach(filteredSongs, id: \.id) { song in
                        SongRow(
                            song: song,
                            toggleAddPlaylists: {}
                        ) {
                            setSelectedSong(song)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        } else {
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding(.top, 20)
            }
        }
    }
}
