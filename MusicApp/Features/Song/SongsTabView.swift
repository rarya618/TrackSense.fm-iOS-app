//
//  SongsTabView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct SongsTabView: View {
    let userToken: String
    
    @EnvironmentObject var overlayManager: OverlayManager
    @EnvironmentObject var songLibraryManager: SongLibraryManager
    
    @State private var selectedSong: Song?
    @State private var searchText = ""
    
    private var filteredSongs: [Song] {
        let songs = songLibraryManager.songs
        guard !searchText.isEmpty else { return songs }

        return songs.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.artistName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedSongs: [String: [Song]] {
        Dictionary(grouping: filteredSongs) { song in
            guard let firstChar = song.title.first else { return "#" }
            let char = String(firstChar).uppercased()
            return char.rangeOfCharacter(from: .letters) != nil ? char : "#"
        }
    }

    private var sortedKeys: [String] {
        groupedSongs.keys.sorted { lhs, rhs in
            if lhs == "#" { return false }
            if rhs == "#" { return true }
            return lhs < rhs
        }
    }
    
    func showMessage(
        _ message: String
    ) async {
        await displayMessage(message, setMessage: overlayManager.showOverlay)
    }
    
    let margin: CGFloat = 20
    
    var body: some View {
        ScrollView {
            TopSpacer()
            
            InlineSearchBar(searchText: $searchText, label: "Search songs")
                .padding(.vertical, 6)
                .padding(.horizontal)
            
            // Inline loading indicator (non-blocking)
            if filteredSongs.isEmpty && !searchText.isEmpty {
                // No search results
                NoResultsView(searchText: searchText)
                
            } else if songLibraryManager.songs.isEmpty {
                // Empty state (only when not loading)
                if !songLibraryManager.isLoading {
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No songs found")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Your library songs will appear here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(margin)
                }
            } else {
                // Songs list (renders as soon as any songs are available)
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(sortedKeys, id: \.self) { key in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(key)
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .padding(.leading, 4)
                            
                            ForEach(groupedSongs[key] ?? [], id: \.id) { song in
                                SongRow(
                                    song: song,
                                    toggleAddPlaylists: {}
                                ) {
                                    selectedSong = song
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .navigationDestination(item: $selectedSong) { song in
            SongView(
                song: song
            )
        }
    }
}
