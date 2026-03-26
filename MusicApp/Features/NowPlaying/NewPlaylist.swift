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
    
    @State private var errorMessage: String?
    @State private var selectedPlaylist: Playlist?

    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    HStack(spacing: 12) {
                        HStack(alignment: .center) {
                            Image(systemName: "plus")
                                .font(Font.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.resonateWhite)
                                .frame(width: 36, height: 36)
                        }
                        .background(Color.resonatePurple)
                        .cornerRadius(20)
                        
                        Text("New Playlist")
                            .font(Font.system(size: 17, weight: .medium))
                            .foregroundStyle(Color.resonatePurple)
                        
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    
                    HStack {
                        Text("All Playlists")
                            .font(Font.system(size: 17, weight: .bold))
                        Spacer()
                    }
                    
                    PlaylistsList(
                        setError: setError,
                        selectPlaylist: selectPlaylist,
                        onlyShowPersonalPlaylists: true
                    )
                }
                .padding(.horizontal, 24)
            }
            
            // 🟣 Overlay section
            if let playlist = selectedPlaylist {
                VStack {
                    Spacer().frame(height: 16)
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.resonatePurple)
                        Text("Added to \(playlist.name)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.resonatePurple)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.resonateWhite)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }

            // 🔴 Optional error overlay
            if let message = errorMessage {
                VStack {
                    Spacer().frame(height: 16)
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Text(message)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.red)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.resonateWhite)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .navigationTitle("Add to a Playlist")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search for Playlists")
    }
    
    func setError(error: String) {
        errorMessage = error
    }

    func selectPlaylist(playlist: Playlist) {
        Task {
            do {
                if let song = song {
                    try await MusicLibrary.shared.add(song, to: playlist)
                    print("✅ Added \(song.title) to \(playlist.name)")

                    await MainActor.run {
                        withAnimation {
                            selectedPlaylist = playlist
                        }
                    }

                    // Auto-hide overlay after 1.5 seconds
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    await MainActor.run {
                        withAnimation {
                            selectedPlaylist = nil
                        }
                    }
                }
            } catch {
                print("❌ Failed to add song to playlist: \(error)")
                await MainActor.run {
                    withAnimation {
                        errorMessage = "Failed to add song"
                    }
                }

                // Hide error after 2 seconds
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    withAnimation {
                        errorMessage = nil
                    }
                }
            }
        }
    }
}
