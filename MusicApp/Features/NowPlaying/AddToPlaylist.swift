//
//  AddToPlaylist.swift
//  TrackSense
//
//  Created by Russal Arya on 6/11/2025.
//

import SwiftUI
import MusicKit

struct AddToPlaylist: View {
    let song: Song?
    let togglePlaylistsSheetVisible: () -> Void
    let color: Color
    let bgColor: Color
    
    @EnvironmentObject var overlayManager: OverlayManager
    
    @State private var isNewPlaylistsSheetVisible: Bool = false

    @State private var searchText = ""
    
    func toggleNewPlaylistsSheetVisible() {
        isNewPlaylistsSheetVisible = !isNewPlaylistsSheetVisible
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Button(action: {toggleNewPlaylistsSheetVisible()}) {
                        HStack(spacing: 12) {
                            HStack(alignment: .center) {
                                Image(systemName: "plus")
                                    .font(Font.montserrat(size: 16, weight: .bold))
                                    .foregroundStyle(bgColor)
                                    .frame(width: 36, height: 36)
                            }
                            .background(color)
                            .cornerRadius(20)
                            
                            Text("New Playlist")
                                .font(Font.montserrat(size: 17, weight: .medium))
                                .foregroundStyle(color)
                            
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    }
                    
                    HStack {
                        Text("All Playlists")
                            .font(Font.montserrat(size: 17, weight: .bold))
                            .foregroundStyle(color)
                        Spacer()
                    }
                    
                    PlaylistsList(
                        selectPlaylist: { playlist in
                            addSongToPlaylist(
                                song: song,
                                playlist: playlist,
                                setOverlayMessage: overlayManager.showOverlay,
                                setErrorMessage: overlayManager.showError
                            )
                            togglePlaylistsSheetVisible()
                        },
                        color: color,
                        onlyShowPersonalPlaylists: true
                    )
                    .foregroundStyle(color)
                }
                .padding(.horizontal, 24)
            }
        }
        .foregroundStyle(color)
        .background(bgColor)
        .navigationTitle("Add to a Playlist")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search for Playlists")
        .sheet(isPresented: $isNewPlaylistsSheetVisible) {
            NavigationStack {
                NewPlaylist(
                    songToAdd: song,
                    togglePlaylistsSheetVisible: togglePlaylistsSheetVisible,
                    toggleNewPlaylistsSheetVisible: toggleNewPlaylistsSheetVisible,
                    color: color,
                    bgColor: bgColor
                )
            }
                .foregroundStyle(color)
                .background(bgColor)
                .presentationDetents([.medium]) // allows swipe-up expansion
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
                .presentationContentInteraction(.automatic)
                .presentationCompactAdaptation(.sheet)
        }
    }
}

func addSongToPlaylist(
    song: Song?,
    playlist: Playlist,
    setOverlayMessage: @escaping (String?) -> Void,
    setErrorMessage: @escaping (String?) -> Void
) {
    addItemToPlaylist(
        item: song,
        playlist: playlist,
        setOverlayMessage: setOverlayMessage,
        setErrorMessage: setErrorMessage
    )
}

func addAlbumToPlaylist(
    album: Album?,
    playlist: Playlist,
    setOverlayMessage: @escaping (String?) -> Void,
    setErrorMessage: @escaping (String?) -> Void
) {
    addItemToPlaylist(
        item: album,
        playlist: playlist,
        setOverlayMessage: setOverlayMessage,
        setErrorMessage: setErrorMessage
    )
}

func addItemToPlaylist<Item: MusicItem & MusicPlaylistAddable>(
    item: Item?,
    playlist: Playlist,
    setOverlayMessage: @escaping (String?) -> Void,
    setErrorMessage: @escaping (String?) -> Void
) {
    Task {
        do {
            guard let item = item else { return }
            let displayTitle: String = {
                if let song = item as? Song { return song.title }
                if let album = item as? Album { return album.title }
                if let musicVideo = item as? MusicVideo { return musicVideo.title }
                return "Item"
            }()
            try await MusicLibrary.shared.add(item, to: playlist)
            print("Added \(displayTitle) to \(playlist.name)")
            
            await MainActor.run {
                withAnimation {
                    setOverlayMessage("\(displayTitle) added to \(playlist.name)")
                }
            }
            
            // Auto-hide overlay after 1.5 seconds
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                withAnimation {
                    setOverlayMessage(nil)
                }
            }
        } catch {
            print("Failed to add song to playlist: \(error)")
            await MainActor.run {
                withAnimation {
                    setErrorMessage("Failed to add song")
                }
            }
            
            // Hide error after 2 seconds
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                withAnimation {
                    setErrorMessage(nil)
                }
            }
        }
    }
}

