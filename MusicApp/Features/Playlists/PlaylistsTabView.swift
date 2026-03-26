//
//  PlaylistsTabView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct PlaylistsTabView: View {
    let userToken: String
    
    @State private var errorMessage: String?
    @State private var selectedPlaylist: Playlist?
    
    var body: some View {
        ScrollView {
            TopSpacer()
            
            PlaylistsList(
                selectPlaylist: selectPlaylist,
                color: .resonatePurple,
                onlyShowPersonalPlaylists: false
            )
            .padding(.horizontal)
        }
        .navigationDestination(item: $selectedPlaylist) { playlist in
            PlaylistView(playlist: playlist)
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    func setError(error: String) {
        errorMessage = error
    }

    func selectPlaylist(playlist: Playlist) {
        selectedPlaylist = playlist
    }
}

struct PlaylistsList: View {
    var selectPlaylist: (Playlist) -> Void
    let color: Color
    let onlyShowPersonalPlaylists: Bool
    
    @EnvironmentObject var overlayManager: OverlayManager

    @State private var playlists: MusicItemCollection<Playlist> = []
    
    var body: some View {
        LazyVStack(spacing: 8) {
            if onlyShowPersonalPlaylists {
                ForEach(playlists, id: \.id) { playlist in
                    if playlist.kind == .userShared {
                        MusicItemBlock(
                            artwork: playlist.artwork,
                            title: playlist.name,
                            artistName: playlist.curatorName,
                            playCount: nil,
                            removeSpacer: false,
                            removeEllipsis: true,
                            primaryColor: color,
                            secondaryColor: color.opacity(0.9)
                        ) {
                            selectPlaylist(playlist)
                        }
                    }
                }
            } else {
                ForEach(playlists, id: \.id) { playlist in
                    MusicItemBlock(
                        artwork: playlist.artwork,
                        title: playlist.name,
                        artistName: playlist.curatorName,
                        playCount: nil,
                        removeSpacer: false,
                        removeEllipsis: false,
                        primaryColor: color
                    ) {
                        selectPlaylist(playlist)
                    }
                }
            }
        }
        .task {
            await fetchLibraryPlaylists()
        }
    }

    func fetchLibraryPlaylists() async {
        do {
            // Fetch user's library playlists
            let request = MusicLibraryRequest<Playlist>()
            let response = try await request.response()

            // Sort by lastModifiedDate descending (newest first). Missing dates go to the end.
            let sorted = response.items.sorted { lhs, rhs in
                let l = lhs.lastModifiedDate
                let r = rhs.lastModifiedDate
                switch (l, r) {
                case let (.some(ld), .some(rd)):
                    return ld > rd
                case (nil, .some):
                    // place nil after any real date
                    return false
                case (.some, nil):
                    // place real date before nil
                    return true
                case (nil, nil):
                    return false
                }
            }

            await MainActor.run {
                // Wrap back into MusicItemCollection
                playlists = MusicItemCollection(sorted)
            }
        } catch {
            await MainActor.run {
                overlayManager.showError("Failed to fetch playlists: \(error.localizedDescription)")
            }
        }
    }
}
