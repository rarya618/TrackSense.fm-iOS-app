//
//  SongView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit
import FirebaseDatabase
import Charts

protocol SongOrTrack: PlayableMusicItem {
    var title: String { get }
    var artistName: String { get }
    var albumTitle: String? { get }
}

extension Song: SongOrTrack {}
extension Track: SongOrTrack {}

// MARK: - Play operations
func playSong(
    _ song: Song,
    showMessage: @escaping (String) async -> Void,
    showError: @escaping (String) async -> Void
) {
    Task {
        await playItem(song) { error in
            Task { await showError("Playback failed: \(error.localizedDescription)") }
        }
    }
}

func addToPlayNext(
    _ item: some SongOrTrack,
    showMessage: @escaping (String) async -> Void,
    showError: @escaping (String) async -> Void
) {
    Task {
        await playItem(item, playImmediately: false) { error in
            Task { await showError("Playback failed: \(error.localizedDescription)") }
        }
        
        await showMessage("Playing next: " + item.title)
    }
}

func addToQueue(
    _ item: SongOrTrack,
    showMessage: @escaping (String) async -> Void,
    showError: @escaping (String) async -> Void
) {
    Task {
        await playItem(item, playImmediately: false, addToEndOfQueue: true) { error in
            Task { await showError("Playback failed: \(error.localizedDescription)") }
        }
        
        await showMessage("Added to queue: " + item.title)
    }
}

// MARK: - Song View
struct SongView: View {
    let song: Song
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var overlayManager: OverlayManager

    @State private var isAddPlaylistsSheetVisible: Bool = false
    @State private var isMenuVisible: Bool = false
    @State private var cloudSongData: SongFromCloud?
    
    @State private var songAlbum: Album?
    @State private var songArtist: Artist?
    
    // MARK: - Colors
    private var artworkColor: Color {
        if let cgColor = song.artwork?.backgroundColor {
            return Color(cgColor)
        } else {
            return Color.landingPurple
        }
    }
    
    private var primaryColor: Color {
        if let cgColor = song.artwork?.primaryTextColor {
            return Color(cgColor)
        } else {
            return .buttonLabelColor
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
    
    private var betterTextColor: Color {
        // depend on colorScheme to force recalculation on toggle
        _ = colorScheme

        if let textCG = song.artwork?.primaryTextColor,
           let bgCG = song.artwork?.backgroundColor {
                let textColor = UIColor(cgColor: textCG)
                let bgColor = UIColor(cgColor: bgCG)
                return idealColor(textColor: textColor, backgroundColor: bgColor)
        }
        return .resonatePurple
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    DetailsView(
                        musicItem: song,
                        artwork: song.artwork,
                        title: song.title,
                        artistName: song.artistName,
                        albumTitle: song.albumTitle,
                        genreNames: song.genreNames,
                        playMusicItem: { playSong(song,
                                                  showMessage: showMessage,
                                                  showError: showError)},
                        duration: song.duration,
                        isAppleDigitalMaster: song.isAppleDigitalMaster,
                        audioVariants: song.audioVariants,
                        toggleMenu: toggleMenuSheet
                    )
                    
                    // MARK: - Content
                    VStack(spacing: 20) {
                        SongStatsView(
                            song: song,
                            cloudData: cloudSongData,
                            color: betterTextColor
                        )
                        
                        ViewSpacer()
                    }
                    .foregroundColor(betterTextColor)
                    .padding(.top, 24)
                    .frame(maxWidth: .infinity)
                    .background(Color.resonateWhite.ignoresSafeArea(edges: .bottom))
                    .cornerRadius(20)
                }
            }
            .ignoresSafeArea(edges: .vertical) // extend under status bar
            .background(artworkColor)
        }
        .onAppear {
            Task { await getSongFromRealtimeDatabase() }
        }
        .sheet(isPresented: $isAddPlaylistsSheetVisible) {
            NavigationStack {
                AddToPlaylist(
                    song: song,
                    togglePlaylistsSheetVisible: toggleAddPlaylistsSheet,
                    color: .resonatePurple,
                    bgColor: .resonateWhite
                )
            }
                .foregroundStyle(Color.resonatePurple)
                .background(Color.resonateWhite)
                .presentationDetents([.medium, .large]) // allows swipe-up expansion
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isMenuVisible) {
            NavigationStack {
                CustomMenu (
                    artwork: song.artwork,
                    title: song.title,
                    subtitle: song.artistName,
                    color: betterTextColor,
                    menuItems: getMenuForSong(
                        song,
                        showMessage: { msg in await showMessage(msg) },
                        showError: { msg in await showError(msg) },
                        toggleAddPlaylists: toggleAddPlaylistsSheet,
                        goToAlbum: goToAlbum,
                        goToArtist: goToArtist
                    )
                )
            }
            .background(Color.resonateWhite)
            .presentationDetents([.height(450)])
            .presentationDragIndicator(.visible)
        }
        .navigationDestination(item: $songAlbum) { album in
            AlbumView(album: album)
        }
        .navigationDestination(item: $songArtist) { artist in
            ArtistView(artist: artist)
        }
    }
    
    func goToAlbum() {
        Task {
            do {
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
    
    func toggleMenuSheet() {
        isMenuVisible.toggle()
    }
    
    func toggleAddPlaylistsSheet() {
        isAddPlaylistsSheetVisible.toggle()
    }
    
    /// Gets the song from the Firebase Realtime Database
    func getSongFromRealtimeDatabase() async {
        guard let userID = authManager.userID else {
            Task {
                await showError("Not logged in")
            }
            return
        }
        
        cloudSongData = await getItemFromDatabase(
            id: song.id,
            userID: userID,
            type: "songs",
            showError: { msg in await showError(msg) }
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

func displayMessage(
    _ message: String,
    setMessage: (String?) -> Void
) async {
    setMessage(message)
    
    // Auto-hide overlay after 1.5 seconds
    try? await Task.sleep(nanoseconds: 1_500_000_000)
    await MainActor.run {
        withAnimation {
            setMessage(nil)
        }
    }
}

