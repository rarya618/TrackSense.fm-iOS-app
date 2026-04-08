//
//  PlaylistView.swift
//  Resonate
//
//  Created by Russal Arya on 9/10/2025.
//

import SwiftUI
import MusicKit

struct PlaylistView: View {
    let playlist: Playlist
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var overlayManager: OverlayManager
    
    @State private var errorMessage: String?
    @State private var tracks: MusicItemCollection<Track>
    @State private var selectedTrack: Track?
    @State private var currentSection = 0
    
    @State private var isAddPlaylistsSheetVisible: Bool = false
    @State private var isMenuVisible: Bool = false
    
    var playCount: Int { getTotalPlayCount(tracks) }
    var timePlayed: Double { getTotalTimePlayed(tracks) }

    init(playlist: Playlist) {
        self.playlist = playlist
        _tracks = State(initialValue: playlist.tracks ?? MusicItemCollection([]))
    } 
    
    private var adjustedArtworkColor: Color {
        // depend on colorScheme to force recalculation on toggle
        _ = colorScheme
        
        if let bgCG = playlist.artwork?.backgroundColor,
            let textCG = playlist.artwork?.primaryTextColor {
            let textColor = UIColor(cgColor: textCG)
            let bgColor = UIColor(cgColor: bgCG)
                
            return idealColor(textColor: textColor, backgroundColor: bgColor)
        }

        return .resonatePurple
    }
    
    private var artworkColor: Color {
        if let cgColor = playlist.artwork?.backgroundColor {
            return Color(cgColor)
        } else {
            return Color.landingPurple
        }
    }
    
    var body: some View {
        // NavigationStack {
            ScrollView {
                // Playlist details
                VStack(spacing: 18) {
                    DetailsView(
                        musicItem: playlist,
                        artwork: playlist.artwork,
                        title: playlist.name,
                        artistName: playlist.curatorName ?? "",
                        albumTitle: nil,
                        genreNames: [],
                        playMusicItem: {playPlaylist(playlist)},
                        duration: nil,
                        isAppleDigitalMaster: false,
                        audioVariants: [],
                        toggleMenu: toggleMenuSheet
                    )
                    
                    VStack {
                        HStack {
                            CustomPicker(
                                color: adjustedArtworkColor,
                                currentSection: currentSection,
                                setCurrentSection: setCurrentSection,
                                options: [
                                    "Tracks",
                                    "Stats"
                                ]
                            )
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 12)
                        .padding(.leading, 2)

                        VStack {
                            if currentSection == 0 {
                                // Playlist tracks
                                PlaylistTracksView (
                                    tracks: tracks,
                                    adjustedArtworkColor: adjustedArtworkColor,
                                    setSelectedTrack: setSelectedTrack
                                )
                            }
                            else if currentSection == 1 {
                                VStack(alignment: .leading, spacing: 20) {
                                    TrackChartView(tracks: tracks)
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Stats")
                                            .fontWeight(.bold)
                                            .font(.system(size: 24))
                                        
                                        // Playlist Stats
                                        PlaylistStatsView (
                                            playlist: playlist,
                                            playCount: playCount,
                                            timePlayed: timePlayed
                                        )
                                        .foregroundColor(adjustedArtworkColor)
                                    }
                                    .padding(.top, 22)
                                    .padding(.bottom, 20)
                                    .padding(.horizontal, 20)
                                    .glassEffect(in: RoundedRectangle(cornerRadius: 16))
                                }
                            }
                        }
                        .padding(.horizontal, 22)

                        ViewSpacer()
                    }
                    .padding(.top, 24)
                    .background(Color.resonateWhite)
                    .frame(maxHeight: .infinity)
                    .cornerRadius(28)
                }
            }
            .sheet(isPresented: $isMenuVisible) {
                NavigationStack {
                    CustomMenu (
                        artwork: playlist.artwork,
                        title: playlist.name,
                        subtitle: playlist.curatorName,
                        color: adjustedArtworkColor,
                        menuItems: getMenuForPlaylist(
                            playlist,
                            showMessage: { msg in await showMessage(msg) },
                            showError: { msg in await showError(msg) },
                            toggleAddPlaylists: toggleAddPlaylistsSheet
                        )
                    )
                }
                    .background(Color.resonateWhite)
                    .presentationDetents([.height(450)])
                    .presentationDragIndicator(.visible)
            }
            .ignoresSafeArea(edges: .vertical) // extend under status bar
            .background(artworkColor)
            .navigationDestination(item: $selectedTrack) { track in
                TrackView(track: track)
            }
            .onAppear {
                Task {
                    if playlist.tracks == nil {
                        do {
                            let fullPlaylist = try await playlist.with([.tracks])
                            tracks = fullPlaylist.tracks ?? MusicItemCollection([])

                        } catch {
                            errorMessage = "Failed to load tracks"
                        }
                    }
                }
            }
        // }
    }
    
    func toggleMenuSheet() {
        isMenuVisible.toggle()
    }
    
    func toggleAddPlaylistsSheet() {
        isAddPlaylistsSheetVisible.toggle()
    }

    func setCurrentSection(_ index: Int) {
        currentSection = index
    }

    func setSelectedTrack(_ track: Track) {
        selectedTrack = track
    }
    
    func playPlaylist(_ playlist: Playlist) {
        Task {
            await playItem(playlist) { error in
                errorMessage = "Playback failed: \(error.localizedDescription)"
            }
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Show Overlays
    func showMessage(_ message: String) async {
        await displayMessage(message) { msg in
            overlayManager.showOverlay(msg)
        }
    }

    func showError(_ message: String) async {
        await displayMessage(message) { msg in
            overlayManager.showError(msg)
        }
    }
}

func addPlaylistToPlayNext(
    _ playlist: Playlist,
    showMessage: @escaping (String) async -> Void,
    showError: @escaping (String) async -> Void
) {
    Task {
        await playItem(playlist, playImmediately: false) { error in
            Task { await showError("Playback failed: \(error.localizedDescription)") }
        }
        
        await showMessage("Playing next: " + playlist.name)
    }
}

func addPlaylistToQueue(
    _ playlist: Playlist,
    showMessage: @escaping (String) async -> Void,
    showError: @escaping (String) async -> Void
) {
    Task {
        await playItem(playlist, playImmediately: false, addToEndOfQueue: true) { error in
            Task { await showError("Playback failed: \(error.localizedDescription)") }
        }
        
        await showMessage("Added to queue: " + playlist.name)
    }
}
