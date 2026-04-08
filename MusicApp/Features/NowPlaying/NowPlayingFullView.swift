//
//  NowPlayingFullView.swift
//  Resonate
//
//  Created by Russal Arya on 22/9/2025.
//

import SwiftUI
import MusicKit
import MediaPlayer
import AVFoundation
import UIKit
import CoreImage

extension UIColor {
    var isDarkColor: Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Slightly higher threshold gives better contrast for “near dark” colors
        return luminance < 0.6
    }
}

extension Color {
    /// Adjusts perceived brightness by adding a delta to the brightness component in HSB space.
    /// Positive values lighten, negative values darken. Range typically [-1, 1].
    func adjusted(brightness delta: CGFloat) -> Color {
        // Attempt to convert to UIColor to manipulate components
        #if canImport(UIKit)
        // Resolve to a UIColor in the current trait environment as best-effort
        let uiColor = UIColor(self)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            let newB = max(0.0, min(1.0, b + delta))
            return Color(hue: Double(h), saturation: Double(s), brightness: Double(newB), opacity: Double(a))
        } else {
            // Fallback: linearly blend toward white/black depending on sign
            if delta >= 0 {
                return self.opacity(1).blend(with: .white, amount: min(1, delta))
            } else {
                return self.opacity(1).blend(with: .black, amount: min(1, -delta))
            }
        }
        #else
        return self
        #endif
    }

    /// Simple blend helper for fallback path.
    private func blend(with other: Color, amount: CGFloat) -> Color {
        // Convert both to UIColor and interpolate in RGBA space
        #if canImport(UIKit)
        let c1 = UIColor(self)
        let c2 = UIColor(other)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        c1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        c2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let t = max(0.0, min(1.0, amount))
        let r = r1 + (r2 - r1) * t
        let g = g1 + (g2 - g1) * t
        let b = b1 + (b2 - b1) * t
        let a = a1 + (a2 - a1) * t
        return Color(UIColor(red: r, green: g, blue: b, alpha: a))
        #else
        return self
        #endif
    }
}

@MainActor
func updateNowPlayingInfoFromSystemPlayer() async {
    let player = SystemMusicPlayer.shared

    guard let entry = player.queue.currentEntry else {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        return
    }

    if case let .song(song) = entry.item {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artistName,
            MPMediaItemPropertyAlbumTitle: song.albumTitle ?? "",
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player.playbackTime,
            MPNowPlayingInfoPropertyPlaybackRate:
                player.state.playbackStatus == .playing ? 1.0 : 0.0
        ]

        if let artwork = song.artwork,
           let url = artwork.url(width: 600, height: 600) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    let mpArtwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    info[MPMediaItemPropertyArtwork] = mpArtwork
                }
            } catch {
                // If artwork download fails, proceed without artwork
                // print("Failed to load artwork image: \(error)")
            }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}

struct NowPlayingFullView: View {
    @Binding var isPlayerExpanded: Bool
    let goToAlbum: () -> Void
    let goToArtist: () -> Void
    
    @EnvironmentObject var overlayManager: OverlayManager
    @EnvironmentObject var authManager: AuthManager
    
    @State private var lastErrorMessage: String? = nil
    
    @State private var currentSong: Song?
    @State private var cloudSongData: SongFromCloud?
    
    @State private var refreshTask: Task<Void, Never>? = nil
    
    @State private var isPlaying: Bool = false

    // Added views handler
    @State private var isStatsVisible: Bool = false
    @State private var isPlaylistsSheetVisible: Bool = false
    @State private var isQueueVisible: Bool = false
    @State private var isLyricsVisible: Bool = false
    @State private var isMenuVisible: Bool = false
    @State private var isPlayerMinimised: Bool = false

    @State private var isSongInLibrary: Bool = false

    @State private var playbackTime: TimeInterval = SystemMusicPlayer.shared.playbackTime

    // Tracks output source
    @State private var currentOutputName: String = "iPhone"
    @State private var currentOutputIcon: String = "speaker.wave.2.fill"
    
    // Drag state
    @State private var dragOffset: CGFloat = 0
    
    func togglePlayerMinimise() {
        isPlayerMinimised.toggle()
    }

    func toggleStatsVisible() {
        isStatsVisible.toggle()
    }
    
    func togglePlaylistsSheetVisible() {
        isPlaylistsSheetVisible.toggle()
    }
    
    func toggleQueue() {
        isQueueVisible.toggle()
    }
    
    func toggleLyrics() {
        isLyricsVisible.toggle()
    }
    
    func closePlayer() {
        isPlayerExpanded.toggle()
    }

    private var artworkColor: Color {
        if let cgColor = currentSong?.artwork?.backgroundColor {
            return Color(cgColor)
        } else {
            return Color.landingPurple
        }
    }

    private var primaryColor: Color {
        guard
            let textCG = currentSong?.artwork?.primaryTextColor
        else {
            return .white
        }

        let appleText = UIColor(cgColor: textCG)
        
        return Color(appleText)
    }
    
    private var secondaryColor: Color { artworkColor.adjusted(brightness: -0.2) } // Slightly deeper
    private var highlightColor: Color { artworkColor.adjusted(brightness: 0.2) }  // Slightly lighter
    
    var body: some View {
        ZStack {
            // Background derived from artwork
//            artworkColor
//                .ignoresSafeArea()
            
//            Color.resonateWhite
//                .ignoresSafeArea()
            
//            LinearGradient(
//                colors: [
//                    artworkColor.opacity(0.35),
//                    artworkColor.opacity(0.65),
//                    artworkColor.opacity(0.85),
//                    artworkColor.opacity(0.95)
//                ],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()

            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5, 0.5], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: [
                    artworkColor, highlightColor, artworkColor,
                    secondaryColor, artworkColor, highlightColor,
                    artworkColor, secondaryColor, artworkColor
                ]
            )
            .ignoresSafeArea()
            
            if let song = currentSong {
                VStack (spacing: 8) {
                    HStack {
                        Button(action: closePlayer) {
                            Image(systemName: "xmark")
                                .font(Font.montserrat(size: 20, weight: .bold))
                                .foregroundColor(primaryColor)
                                .frame(width: 36, height: 36)
//                                .background(primaryColor.opacity(0.16))
//                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("Now playing")
                            .font(Font.montserrat(size: 16, weight: .bold))
                            .foregroundColor(primaryColor)
                        
                        Spacer()
                        
                        Button(action: toggleMenuSheet) {
                            Image(systemName: "ellipsis")
                                .font(Font.montserrat(size: 20, weight: .bold))
                                .foregroundColor(primaryColor)
                                .frame(width: 36, height: 36)
//                                .background(primaryColor.opacity(0.12))
                                .clipShape(Circle())
//                                .glassEffect(.clear)
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 8)
//                    Capsule()
//                        .fill(primaryColor)
//                        .frame(width: 56, height: 5)
//                        .padding(.top, 12)
//                        .padding(.bottom, 4)

                    MediaPlayerView(
                        song: song,
                        isPlaying: isPlaying,
                        isPlayerMinimised: isPlayerMinimised,
                        isSongInLibrary: isSongInLibrary,
                        playbackTime: playbackTime,
                        togglePlayPause: togglePlayPause,
                        artworkColor: artworkColor,
                        primaryColor: primaryColor,
                        toggleMenu: toggleMenuSheet
                    )
                    
                    Spacer()

                    BottomBar(
                        isStatsVisible: isStatsVisible,
                        artworkColor: artworkColor,
                        primaryColor: primaryColor,
                        currentOutputIcon: currentOutputIcon,
                        currentOutputName: currentOutputName,
                        toggleStatsVisible: toggleStatsVisible,
                        togglePlaylistsSheetVisible: togglePlaylistsSheetVisible,
                        toggleQueue: toggleQueue,
                        toggleLyrics: toggleLyrics
                    )
                    .padding(.horizontal, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // makes it full width
                .padding(.top, 36)
                .padding(.bottom, 48)
                .padding(.horizontal, 20)
            } else {
                Text("Nothing playing")
                    .foregroundStyle(Color.white)
            }

            VStack {
                Spacer().frame(height: 32)
                MessageOverlays(
                    overlayMessage: overlayManager.overlayMessage,
                    errorMessage: overlayManager.errorMessage
                )
            }
        }
        .onAppear {
            refreshTask?.cancel()
            refreshTask = Task {
                var lastSongID: MusicItemID? = nil
                while !Task.isCancelled {
                    await fetchCurrentlyPlayingWithLibraryData()
                    await getSongFromRealtimeDatabase()

                    // Update Now Playing Info only when song changes
                    if currentSong?.id != lastSongID {
                        await updateNowPlayingInfoFromSystemPlayer()
                        lastSongID = currentSong?.id
                    }

                    // Update playback progress more smoothly
                    playbackTime = SystemMusicPlayer.shared.playbackTime

                    try? await Task.sleep(nanoseconds: 500_000_000) // smoother updates
                }
            }
            updateCurrentRoute()
            NotificationCenter.default.addObserver(
                forName: AVAudioSession.routeChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                updateCurrentRoute()
            }
        }
        .onDisappear {
            refreshTask?.cancel()
            refreshTask = nil
        }
        .sheet(isPresented: $isPlaylistsSheetVisible) {
            NavigationStack {
                AddToPlaylist(
                    song: currentSong,
                    togglePlaylistsSheetVisible: togglePlaylistsSheetVisible,
                    color: .resonatePurple,
                    bgColor: .resonateWhite
                )
            }
                .presentationDetents([.medium, .large]) // allows swipe-up expansion
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.automatic)
                .presentationCompactAdaptation(.sheet)
        }
        .sheet(isPresented: $isStatsVisible) {
            NavigationStack {
                PlayerStatsView(
                    song: currentSong,
                    cloudData: cloudSongData,
                    setOverlayMessage: overlayManager.showOverlay,
                    setErrorMessage: overlayManager.showError,
                    color: .resonatePurple,
                    bgColor: .resonateWhite
                )
            }
            .presentationDetents([.medium, .large]) // allows swipe-up expansion
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.automatic)
            .presentationCompactAdaptation(.sheet)
        }
        .sheet(isPresented: $isQueueVisible) {
            NavigationStack {
                QueueView(
                    color: .resonatePurple,
                    bgColor: .resonateWhite
                )
            }
            .presentationDetents([.medium, .large]) // allows swipe-up expansion
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.automatic)
            .presentationCompactAdaptation(.sheet)
        }
        .sheet(isPresented: $isLyricsVisible) {
            NavigationStack {
                LyricsView(
                    color: .resonatePurple,
                    bgColor: .resonateWhite
                )
            }
            .presentationDetents([.medium, .large]) // allows swipe-up expansion
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.automatic)
            .presentationCompactAdaptation(.sheet)
        }
        .sheet(isPresented: $isMenuVisible) {
            NavigationStack {
                if let song = currentSong {
                    CustomMenu (
                        artwork: song.artwork,
                        title: song.title,
                        subtitle: song.artistName,
                        color: artworkColor,
                        menuItems: getMenuForSong(
                            song,
                            showMessage: { msg in await showMessage(msg) },
                            showError: { msg in await showError(msg) },
                            toggleAddPlaylists: togglePlaylistsSheetVisible,
                            goToAlbum: {
                                goToAlbum()
                                
                                toggleMenuSheet()
                            },
                            goToArtist: {
                                goToArtist()
                                
                                toggleMenuSheet()
                            }
                        )
                    )
                }
            }
                .background(Color.resonateWhite)
                .presentationDetents([.height(450)]) // allows swipe-up expansion
                .presentationDragIndicator(.visible)
        }

        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(40)
        .ignoresSafeArea()
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isStatsVisible)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                // threshold to dismiss
                if value.translation.height > 150 {
                    withAnimation(.spring()) {
                        isPlayerExpanded = false
                    }
                } else {
                    withAnimation(.spring()) {
                        dragOffset = 0
                    }
                }
            }
        )
    }
    
    private func toggleMenuSheet() {
        isMenuVisible.toggle()
    }
    
    private func togglePlayPause() {
        Task { @MainActor in
            let player = SystemMusicPlayer.shared
            do {
                if isPlaying {
                    // Optimistically update
                    isPlaying = false
                    player.pause()
                } else {
                    // Optimistically update
                    isPlaying = true
                    try await player.play()
                }
            } catch {
                print("Failed to toggle playback: \(error)")
                // Roll back state if something failed
                isPlaying = player.state.playbackStatus == .playing
            }
        }
    }

    func updateCurrentRoute() {
        let session = AVAudioSession.sharedInstance()
        guard let output = session.currentRoute.outputs.first else {
            currentOutputName = "Unknown"
            currentOutputIcon = "speaker.wave.2.fill"
            return
        }

        let portType = output.portType
        currentOutputName = output.portName

        switch portType {
        case .bluetoothA2DP, .bluetoothLE, .bluetoothHFP:
            // Usually AirPods, Beats, or Bluetooth speakers
            currentOutputIcon = "airpodspro" // system SF Symbol available iOS 17+
        case .headphones, .headsetMic:
            currentOutputIcon = "headphones"
        case .builtInSpeaker:
            currentOutputIcon = "speaker.wave.2.fill"
        case .airPlay:
            currentOutputIcon = "airplayaudio"
        default:
            currentOutputIcon = "speaker.wave.2.fill"
        }
    }
    
    @MainActor
    func fetchCurrentlyPlayingWithLibraryData() async {
        let player = SystemMusicPlayer.shared
        
        // Keep `isPlaying` in sync every refresh
        isPlaying = player.state.playbackStatus == .playing

        guard let entry = player.queue.currentEntry else {
            if currentSong != nil { currentSong = nil } // only update if changed
            return
        }

        switch entry.item {
        case .song(let song):
            var updatedSong = song

            // Fetch library data for stats, but only overwrite fields that exist
            do {
                var request = MusicLibraryRequest<Song>()
                request.filter(matching: \.id, equalTo: song.id)
                let response = try await request.response()
                isSongInLibrary = !response.items.isEmpty
                if let fullSong = response.items.first {
                    // Only overwrite currentSong if fullSong has extra data
                    updatedSong = fullSong
                }
            } catch {
                // silently ignore
            }

            // Only assign to @State if the ID actually changed
            if currentSong?.id != updatedSong.id {
                currentSong = updatedSong
            }

        default:
            if currentSong != nil { currentSong = nil }
        }
    }
    
    /// Gets the song from the Firebase Realtime Database
    func getSongFromRealtimeDatabase() async {
        guard let userID = authManager.userID else {
            Task {
                await showError("Not logged in")
            }
            return
        }
        
        if let song = currentSong {
            cloudSongData = await getItemFromDatabase(
                id: song.id,
                userID: userID,
                type: "songs",
                showError: { msg in await showError(msg) }
            )
        }
    }
    
    // MARK: - Show Overlays
    func showMessage(_ message: String) async {
        await displayMessage(message) { msg in
            overlayManager.showOverlay(msg)
        }
    }

    func showError(_ message: String) async {
        // Only show if it's a different error from last time
        guard message != lastErrorMessage else { return }
        lastErrorMessage = message
        await displayMessage(message) { msg in
            overlayManager.showError(msg)
        }
        // Clear after a delay so same error can show again later if needed
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        lastErrorMessage = nil
    }
}

/// Queues a MusicKit item (Album, Song, Playlist, etc.) to play immediately, without clearing existing items.
/// - Parameters:
///   - item: The MusicKit item to queue.
///   - playImmediately: Whether to start playing the new item right away (default: true).
///   - clearExistingItems: Whether to clear existing queue items (default: false).
///   - addToEndOfQueue: Whether to add to the end of the queue (default: false).
///   - errorHandler: Optional closure to handle playback errors.
func playItem<Item: PlayableMusicItem>(
    _ item: Item,
    playImmediately: Bool = true,
    clearExistingItems: Bool = false,
    addToEndOfQueue: Bool = false,
    errorHandler: ((Error) -> Void)? = nil
) async {
    let player = SystemMusicPlayer.shared

    do {
        if clearExistingItems {
            // Replace the entire queue with this item
            let newQueue = SystemMusicPlayer.Queue(for: [item])
            player.queue = newQueue
            
            if playImmediately {
                try await player.play()
            }
        } else {
            // Insert the item after the current entry without clearing the queue
            try await player.queue.insert([item], position: addToEndOfQueue ? .tail : .afterCurrentEntry)
            
            if playImmediately {
                // Switch to next song
                try await player.skipToNextEntry()
                
                try await player.play()
            }
        }
    } catch {
        errorHandler?(error)
    }
}
