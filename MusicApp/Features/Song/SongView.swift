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
    var artwork: Artwork? { get }
    var genreNames: [String] { get }
    var playCount: Int? { get }
    var lastPlayedDate: Date? { get }
    var libraryAddedDate: Date? { get }
    var releaseDate: Date? { get }
    var trackNumber: Int? { get }
    var duration: TimeInterval? { get }
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
    private enum Item {
        case song(Song)
        case track(Track)
    }
    private let item: Item

    init(song: Song) { self.item = .song(song) }
    init(track: Track) { self.item = .track(track) }

    private var songOrTrack: any SongOrTrack {
        switch item {
        case .song(let s): return s
        case .track(let t): return t
        }
    }

    private var maybeSong: Song? {
        if case .song(let s) = item { return s }
        return nil
    }

    private var asMusicItem: any MusicItem {
        switch item {
        case .song(let s): return s
        case .track(let t): return t
        }
    }

    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var overlayManager: OverlayManager

    @State private var isAddPlaylistsSheetVisible: Bool = false
    @State private var isMenuVisible: Bool = false
    @State private var cloudData: SongFromCloud?

    @State private var songAlbum: Album?
    @State private var songArtist: Artist?
    @State private var cachedTextColor: Color = .resonatePurple

    // MARK: - Colors
    private var artworkColor: Color {
        if let cgColor = songOrTrack.artwork?.backgroundColor {
            return Color(cgColor)
        } else {
            return Color.landingPurple
        }
    }

    private func computeTextColor() -> Color {
        if let textCG = songOrTrack.artwork?.primaryTextColor,
           let bgCG = songOrTrack.artwork?.backgroundColor {
            let textColor = UIColor(cgColor: textCG)
            let bgColor = UIColor(cgColor: bgCG)
            return idealColor(textColor: textColor, backgroundColor: bgColor)
        }
        return .resonatePurple
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                DetailsView(
                    musicItem: asMusicItem,
                    artwork: songOrTrack.artwork,
                    title: songOrTrack.title,
                    artistName: songOrTrack.artistName,
                    albumTitle: songOrTrack.albumTitle,
                    genreNames: songOrTrack.genreNames,
                    playMusicItem: { playCurrentItem() },
                    duration: songOrTrack.duration,
                    isAppleDigitalMaster: maybeSong?.isAppleDigitalMaster,
                    audioVariants: maybeSong?.audioVariants,
                    toggleMenu: toggleMenuSheet,
                    goToAlbum: goToAlbum
                )

                // MARK: - Content
                VStack(spacing: 20) {
                    SongStatsView(
                        song: songOrTrack,
                        cloudData: cloudData,
                        color: cachedTextColor
                    )

                    ViewSpacer()
                }
                .foregroundColor(cachedTextColor)
                .padding(.top, 24)
                .frame(maxWidth: .infinity)
                .background(Color.resonateWhite.ignoresSafeArea(edges: .bottom))
                .cornerRadius(20)
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
        .onAppear {
            cachedTextColor = computeTextColor()
            if cloudData == nil {
                Task { await loadCloudData() }
            }
        }
        .onChange(of: colorScheme) { _, _ in
            cachedTextColor = computeTextColor()
        }
        .sheet(isPresented: $isAddPlaylistsSheetVisible) {
            NavigationStack {
                AddToPlaylist(
                    song: maybeSong,
                    togglePlaylistsSheetVisible: toggleAddPlaylistsSheet,
                    color: .resonatePurple,
                    bgColor: .resonateWhite
                )
            }
                .foregroundStyle(Color.resonatePurple)
                .background(Color.resonateWhite)
                .presentationDetents([.medium, .large]) // allows swipe-up expansion
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
        }
        .sheet(isPresented: $isMenuVisible) {
            NavigationStack {
                CustomMenu (
                    artwork: songOrTrack.artwork,
                    title: songOrTrack.title,
                    subtitle: songOrTrack.artistName,
                    color: cachedTextColor,
                    menuItems: getMenuForSong(
                        songOrTrack,
                        showMessage: { msg in await showMessage(msg) },
                        showError: { msg in await showError(msg) },
                        toggleAddPlaylists: toggleAddPlaylistsSheet,
                        goToAlbum: goToAlbum,
                        goToArtist: goToArtist
                    )
                )
            }
            .background(Color.resonateWhite)
            .presentationDetents([.medium, .large]) // allows swipe-up expansion
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
        }
    }

    func goToAlbum() {
        Task {
            do {
                let album: Album?
                switch item {
                case .song(let song):
                    let detailed = try await song.with([.albums])
                    album = detailed.albums?.first
                case .track(let track):
                    var request = MusicLibraryRequest<Song>()
                    request.filter(matching: \.id, equalTo: track.id)
                    let response = try await request.response()
                    if let resolved = response.items.first {
                        let detailed = try await resolved.with([.albums])
                        album = detailed.albums?.first
                    } else {
                        album = nil
                    }
                }

                if let album {
                    await MainActor.run { songAlbum = album }
                } else {
                    await showError("Album not found")
                }
            } catch {
                await showError("Failed to load album")
            }

            await MainActor.run { isMenuVisible = false }
        }
    }

    func goToArtist() {
        Task {
            do {
                let artist: Artist?
                switch item {
                case .song(let song):
                    let detailed = try await song.with([.artists])
                    artist = detailed.artists?.first
                case .track(let track):
                    var request = MusicLibraryRequest<Song>()
                    request.filter(matching: \.id, equalTo: track.id)
                    let response = try await request.response()
                    if let resolved = response.items.first {
                        let detailed = try await resolved.with([.artists])
                        artist = detailed.artists?.first
                    } else {
                        artist = nil
                    }
                }

                if let artist {
                    await MainActor.run { songArtist = artist }
                } else {
                    await showError("Artist not found")
                }
            } catch {
                await showError("Failed to load artist")
            }

            await MainActor.run { isMenuVisible = false }
        }
    }

    func playCurrentItem() {
        Task {
            switch item {
            case .song(let song):
                await playItem(song) { error in
                    Task { await showError("Playback failed: \(error.localizedDescription)") }
                }
            case .track(let track):
                await playItem(track) { error in
                    Task { await showError("Playback failed: \(error.localizedDescription)") }
                }
            }
        }
    }

    func toggleMenuSheet() {
        isMenuVisible.toggle()
    }

    func toggleAddPlaylistsSheet() {
        isAddPlaylistsSheetVisible.toggle()
    }

    func loadCloudData() async {
        guard let userID = authManager.userID else {
            Task { await showError("Not logged in") }
            return
        }

        cloudData = await getItemFromDatabase(
            id: songOrTrack.id,
            userID: userID,
            type: "songs",
            showError: { msg in await showError(msg) }
        )
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
