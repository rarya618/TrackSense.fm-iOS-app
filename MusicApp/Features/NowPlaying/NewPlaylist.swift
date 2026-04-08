//
//  NewPlaylist.swift
//  Resonate
//
//  Created by Russal Arya on 6/11/2025.
//

import SwiftUI
import MusicKit

struct NewPlaylist: View {
    let songToAdd: Song?
    let togglePlaylistsSheetVisible: () -> Void
    let toggleNewPlaylistsSheetVisible: () -> Void
    let color: Color
    let bgColor: Color
    
    @EnvironmentObject var overlayManager: OverlayManager

    @State private var name = ""
    @State private var description = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 24) {
                // Playlist name input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.montserrat(size: 17, weight: .semibold))
                    TextField("Playlist name", text: $name)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(color.opacity(0.06))
                        .cornerRadius(10)
                }
                
                // Playlist description input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (optional)")
                        .font(.montserrat(size: 17, weight: .semibold))
                    TextEditor(text: $description)
                        .scrollContentBackground(.hidden)
                        .frame(height: 100)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(color.opacity(0.06))
                        .cornerRadius(10)
                }
                
                Spacer()
                StandardButton(
                    label: "Create",
                    bgColor: color,
                    color: bgColor,
                    action: {
                        createPlaylist()
                    }
                )
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("New Playlist")
        .navigationBarTitleDisplayMode(.inline)
    }

    func createPlaylist() {
        Task {
            do {
                let playlist = try await MusicLibrary.shared.createPlaylist(
                    name: name,
                    description: description,
                    authorDisplayName: "Resonate"
                )
                print("Created \(name)")
                
                toggleNewPlaylistsSheetVisible()
                togglePlaylistsSheetVisible()

                await MainActor.run {
                    withAnimation {
                        overlayManager.showOverlay("\(name) created")
                    }
                }

                // Auto-hide overlay after 1.5 seconds
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                await MainActor.run {
                    withAnimation {
                        overlayManager.showOverlay(nil)
                    }
                }
                
                if let song = songToAdd {
                    addSongToPlaylist(
                        song: song,
                        playlist: playlist,
                        setOverlayMessage: overlayManager.showOverlay,
                        setErrorMessage: overlayManager.showError
                    )
                    
                    // Auto-hide overlay after 1.5 seconds
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    await MainActor.run {
                        withAnimation {
                            overlayManager.showOverlay(nil)
                        }
                    }
                }
                
            } catch {
                print("Failed to create playlist: \(error)")
                await MainActor.run {
                    withAnimation {
                        overlayManager.showError("Failed to create playlist")
                    }
                }

                // Hide error after 2 seconds
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    withAnimation {
                        overlayManager.showError(nil)
                    }
                }
            }
        }
    }
}

