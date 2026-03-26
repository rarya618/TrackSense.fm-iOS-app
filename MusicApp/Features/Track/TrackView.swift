//
//  TrackView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct TrackView: View {
    let track: Track
    
    @State private var errorMessage: String?
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var overlayManager: OverlayManager
    
    @State private var isAddPlaylistsSheetVisible: Bool = false
    @State private var isMenuVisible: Bool = false
    
    @State private var cloudTrackData: SongFromCloud?
    
    @State private var songAlbum: Album?
    @State private var songArtist: Artist?

    private var artworkColor: Color {
        if let cgColor = track.artwork?.backgroundColor {
            return Color(cgColor)
        } else {
            return Color.landingPurple
        }
    }

    private func idealColor (
        textColor: UIColor,
        backgroundColor: UIColor
    ) -> Color {
        let white = UIColor(.resonateWhite)
        
        let backgroundRatio = backgroundColor.contrastRatio(with: white)
        let textRatio = textColor.contrastRatio(with: white)

        if (textRatio > 4.5) {
            return Color(textColor)
        } else if (textRatio < backgroundRatio) {
            return Color(backgroundColor)
        } else {
            return Color(textColor)
        }
    }
    
    private var textColor: Color {
        // depend on colorScheme to force recalculation on toggle
        _ = colorScheme
        
        if let bgCG = track.artwork?.backgroundColor,
            let textCG = track.artwork?.primaryTextColor {
                let textColor = UIColor(cgColor: textCG)
                let bgColor = UIColor(cgColor: bgCG)
                
                return idealColor(textColor: textColor, backgroundColor: bgColor)
        }

        return .resonatePurple
    }
    
    func toggleMenuSheet() {
        isMenuVisible = !isMenuVisible
    }
    
    func toggleAddPlaylistsSheet() {
        isAddPlaylistsSheetVisible = !isAddPlaylistsSheetVisible
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    DetailsView(
                        musicItem: track,
                        artwork: track.artwork,
                        title: track.title,
                        artistName: track.artistName,
                        albumTitle: track.albumTitle,
                        genreNames: track.genreNames,
                        playMusicItem: {playTrack()},
                        duration: track.duration,
                        isAppleDigitalMaster: false,
                        audioVariants: [],
                        toggleMenu: toggleMenuSheet
                    )
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 18) {
                            // MARK: - Chart Card
                            ChartCard(
                                title: "Play History",
                                cloudData: cloudTrackData,
                                isSong: true
                            )
                            
                            // MARK: - Description
                            Text("This chart shows how your plays have changed over time. Data updates when content is synced to the cloud.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 16)
                                .padding(.horizontal, 12)
                        }
                        
                        if let cloud = cloudTrackData {
                            TrendsCard(
                                history: cloud.history,
                                unitLabel: "plays"
                            )
                        }

                        TrackStatsView(track: track)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 18)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 16))

                        ViewSpacer()
                    }
                    .foregroundColor(textColor)
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .frame(maxWidth: .infinity)
                    .background(Color.resonateWhite.ignoresSafeArea(edges: .bottom))
                    .cornerRadius(40)
                }
            }
            .navigationDestination(item: $songAlbum) { album in
                AlbumView(album: album)
            }
            
            .navigationDestination(item: $songArtist) { artist in
                ArtistView(artist: artist)
            }
            .ignoresSafeArea(edges: .vertical) // extend under status bar
            .background(artworkColor)
        }
        .onAppear {
            Task { await getTrackFromRealtimeDatabase() }
        }
        .sheet(isPresented: $isMenuVisible) {
            NavigationStack {
                CustomMenu (
                    artwork: track.artwork,
                    title: track.title,
                    subtitle: track.artistName,
                    color: textColor,
                    menuItems: getMenuForSong(
                        track,
                        showMessage: { msg in await showMessage(msg) },
                        showError: { msg in await showError(msg) },
                        toggleAddPlaylists: toggleAddPlaylistsSheet,
                        goToAlbum: goToAlbum,
                        goToArtist: goToArtist
                    )
                )
            }
                .foregroundStyle(Color.resonatePurple)
                .background(Color.resonateWhite)
                .presentationDetents([.height(450)]) // allows swipe-up expansion
                .presentationDragIndicator(.visible)
        }
    }
    
    func resolveSong() async throws -> Song {
        let request = MusicCatalogResourceRequest<Song>(
            matching: \.id,
            equalTo: track.id
        )
        let response = try await request.response()
        
        guard let song = response.items.first else {
            await showError("Song not found")
            struct ResolveSongError: Error {}
            throw ResolveSongError()
        }
        
        return song
    }
    
    func goToAlbum() {
        Task {
            do {
                let song = try await resolveSong()
                let detailedSong = try await song.with([.albums])
                
                if let album = detailedSong.albums?.first {
                    await MainActor.run {
                        songAlbum = album
                    }
                } else {
                    await showError("Album not found")
                }
            } catch {
                await showError("Failed to load album")
            }
            
            toggleMenuSheet()
        }
    }
    
    func goToArtist() {
        Task {
            do {
                let song = try await resolveSong()
                let detailedSong = try await song.with([.artists])
                
                if let artist = detailedSong.artists?.first {
                    await MainActor.run {
                        songArtist = artist
                    }
                } else {
                    await showError("Artist not found")
                }
            } catch {
                await showError("Failed to load artist")
            }
            
            toggleMenuSheet()
        }
    }
    
    func playTrack() {
        Task {
            await playItem(track) { error in
                errorMessage = "Playback failed: \(error.localizedDescription)"
            }
        }
    }
    
    /// Gets the track from the Firebase Realtime Database
    func getTrackFromRealtimeDatabase() async {
        guard let userID = authManager.userID else {
            Task {
                await showError("Not logged in")
            }
            return
        }
        
        cloudTrackData = await getItemFromDatabase(
            id: track.id,
            userID: userID,
            type: "songs",
            showError: showError
        )
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

