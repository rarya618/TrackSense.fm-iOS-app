//
//  AddToPlaylist.swift
//  Resonate
//
//  Created by Russal Arya on 6/11/2025.
//

import SwiftUI
import MusicKit

struct AddToPlaylist: View {
    let song: Song?
    let togglePlaylistsSheetVisible: () -> Void
    let setOverlayMessage: (String?) -> Void
    let setErrorMessage: (String?) -> Void
    let color: Color
    let bgColor: Color
    
    @State private var isNewPlaylistsSheetVisible: Bool = false

    @State private var searchText = ""
    
    func toggleNewPlaylistsSheetVisible() {
        isNewPlaylistsSheetVisible = !isNewPlaylistsSheetVisible
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Button (action: {toggleNewPlaylistsSheetVisible()}) {
                        HStack(spacing: 12) {
                            HStack(alignment: .center) {
                                Image(systemName: "plus")
                                    .font(Font.system(size: 16, weight: .bold))
                                    .foregroundStyle(bgColor)
                                    .frame(width: 36, height: 36)
                            }
                            .background(color)
                            .cornerRadius(20)
                            
                            Text("New Playlist")
                                .font(Font.system(size: 17, weight: .medium))
                                .foregroundStyle(color)
                            
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    }
                    
                    HStack {
                        Text("All Playlists")
                            .font(Font.system(size: 17, weight: .bold))
                            .foregroundStyle(color)
                        Spacer()
                    }
                    
                    PlaylistsList(
                        setError: setErrorMessage,
                        selectPlaylist: { playlist in
                            addSongToPlaylist(
                                song: song,
                                playlist: playlist,
                                setOverlayMessage: setOverlayMessage,
                                setErrorMessage: setErrorMessage
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
        .navigationTitle("Add to a Playlist")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search for Playlists")
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor(color)]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(color)]
            
            // optional: make background match your sheet
            appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
            appearance.backgroundColor = UIColor(bgColor)

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        .onDisappear {
            let resetAppearance = UINavigationBarAppearance()
            UINavigationBar.appearance().standardAppearance = resetAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = resetAppearance
        }
        .sheet(isPresented: $isNewPlaylistsSheetVisible) {
            NavigationStack {
                NewPlaylist(
                    songToAdd: song,
                    togglePlaylistsSheetVisible: togglePlaylistsSheetVisible,
                    toggleNewPlaylistsSheetVisible: toggleNewPlaylistsSheetVisible,
                    setOverlayMessage: setOverlayMessage,
                    setErrorMessage: setErrorMessage,
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
    Task {
        do {
            guard let song = song else { return }
            try await MusicLibrary.shared.add(song, to: playlist)
            print("Added \(song.title) to \(playlist.name)")

            await MainActor.run {
                withAnimation {
                    setOverlayMessage("\(song.title) added to \(playlist.name)")
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
