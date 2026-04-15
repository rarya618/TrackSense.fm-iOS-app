//
//  AppRootView.swift
//  TrackSense
//
//  Created by Russal Arya on 17/9/2025.
//

import SwiftUI
import MusicKit
internal import Combine

enum AppState: Equatable {
    case loading
    case unauthenticated
    case authenticated(userToken: String)
}

struct OverlayView: View {
    let icon: String
    let color: Color
    var message: String
    
    var body: some View {
        Spacer().frame(height: 16)
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(message)
                .font(.montserrat(size: 16, weight: .semibold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.resonateWhite)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

struct MessageOverlays: View {
    var overlayMessage: String?
    var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 16) {
            if let message = overlayMessage {
                OverlayView(
                    icon: "checkmark.circle.fill",
                    color: .resonatePurple,
                    message: message
                )
            }
            
            if let error = errorMessage {
                OverlayView(
                    icon: "exclamationmark.triangle.fill",
                    color: .red,
                    message: error
                )
            }
            
            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: overlayMessage)
        .animation(.easeInOut, value: errorMessage)
    }
}

// MARK: - App Root
struct AppRootView: View {
    @EnvironmentObject var overlayManager: OverlayManager
    
    @State private var currentSong: Song?
    @State private var refreshTask: Task<Void, Never>? = nil
    
    @State private var playingSongAlbum: Album?
    @State private var playingSongArtist: Artist?

    @State private var appState: AppState = .loading
    @State private var isPlayerExpanded = false
    @State private var currentPageId = "stats"

    @StateObject private var songLibraryManager = SongLibraryManager()
    @StateObject private var sessionManager = SessionManager()

    func expandPlayer() -> Void {
        isPlayerExpanded = true
    }

    var body: some View {
        ZStack {
            contentLayer
            MessageOverlays(
                overlayMessage: overlayManager.overlayMessage,
                errorMessage: overlayManager.errorMessage
            )
            .zIndex(100)
        }
        .task {
            await bootstrapApp()
        }
    }

    private var contentLayer: some View {
        VStack {
            switch appState {

            case .loading:
                LoadingView()

            case .unauthenticated:
                AuthView { token in
                    UserDefaults.standard.set(token, forKey: "userToken")

                    Task {
                        await songLibraryManager.fetchSongsIfNeeded()

                        await MainActor.run {
                            appState = .authenticated(userToken: token)
                        }
                    }
                }

            case .authenticated(let token):
                mainAppView(token: token)
            }
        }
    }

    @ViewBuilder
    private func mainAppView(token: String) -> some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                Group {
                    switch currentPageId {
                    case "library":
                        LibraryView(userToken: token)
                    case "sessions":
                        SessionsView()
                    default:
                        StatsView(userToken: token)
                    }
                }
                .navigationDestination(item: $playingSongAlbum) { album in
                    AlbumView(album: album)
                }
                .navigationDestination(item: $playingSongArtist) { artist in
                    ArtistView(artist: artist)
                }
                .onAppear {
                    refreshTask?.cancel()
                    refreshTask = Task {
                        var lastSongID: MusicItemID? = nil
                        while !Task.isCancelled {
                            await fetchCurrentlyPlayingWithLibraryData()
                            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s
                            if currentSong?.id != lastSongID {
                                lastSongID = currentSong?.id
                            }
                        }
                    }
                }
                .onDisappear {
                    refreshTask?.cancel()
                    refreshTask = nil
                }
            }

            BottomNav(
                currentPageId: currentPageId,
                setCurrentPageId: setCurrentPageId,
                isPlayerExpanded: isPlayerExpanded,
                expandPlayer: expandPlayer
            )
            .ignoresSafeArea(edges: .bottom)
        }
        .environmentObject(songLibraryManager)
        .environmentObject(sessionManager)
        .fullScreenCover(isPresented: $isPlayerExpanded) {
            NowPlayingFullView(
                isPlayerExpanded: $isPlayerExpanded,
                goToAlbum: goToAlbum,
                goToArtist: goToArtist
            )
            .environmentObject(overlayManager)
            .environmentObject(sessionManager)
            .presentationBackground(.clear)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    func setCurrentPageId(id: String) {
        currentPageId = id
    }
    
    @MainActor
    func fetchCurrentlyPlayingWithLibraryData() async {
        let player = SystemMusicPlayer.shared

        guard let entry = player.queue.currentEntry else {
            if currentSong != nil { currentSong = nil } // only update if changed
            return
        }

        switch entry.item {
        case .song(let song):
            do {
                var request = MusicLibraryRequest<Song>()
                request.filter(matching: \.id, equalTo: song.id)
                let response = try await request.response()

                if let librarySong = response.items.first {
                    if currentSong?.id != librarySong.id {
                        currentSong = librarySong   // library song
                    }
                } else {
                    if currentSong?.id != song.id {
                        currentSong = song          // fallback
                    }
                }
            } catch {
                if currentSong?.id != song.id {
                    currentSong = song              // fallback
                }
            }

        default:
            if currentSong != nil { currentSong = nil }
        }
    }

    private func bootstrapApp() async {
        try? await Task.sleep(nanoseconds: 700_000_000)

        let status = MusicAuthorization.currentStatus

        if status == .authorized,
           let token = UserDefaults.standard.string(forKey: "userToken") {

            await songLibraryManager.fetchSongsIfNeeded()

            await MainActor.run {
                appState = .authenticated(userToken: token)
            }

        } else {
            await MainActor.run {
                appState = .unauthenticated
            }
        }
    }
    
    func goToAlbum() {
        if let song = currentSong {
            Task {
                do {
                    let detailedSong = try await song.with([.albums])
                    if let album = detailedSong.albums?.first {
                        await MainActor.run {
                            playingSongAlbum = album
                        }
                    } else {
                        await showError("Album not found")
                    }
                } catch {
                    await showError("Failed to load album")
                }
                
                isPlayerExpanded.toggle()
            }
        }
    }
    
    func goToArtist() {
        if let song = currentSong {
            Task {
                do {
                    let detailedSong = try await song.with([.artists])
                    if let artist = detailedSong.artists?.first {
                        await MainActor.run {
                            playingSongArtist = artist
                        }
                    } else {
                        await showError("Artist not found")
                    }
                } catch {
                    await showError("Failed to load artist")
                }
                
                isPlayerExpanded.toggle()
            }
        }
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

struct BottomNav: View {
    var currentPageId: String
    let setCurrentPageId: (String) -> Void
    var isPlayerExpanded: Bool
    let expandPlayer: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            NowPlayingView(isPlayerExpanded: isPlayerExpanded)
                .contentShape(Rectangle())
                .onTapGesture {
                    expandPlayer()
                }
            
            HStack {
                HStack(spacing: 4) {
                    BottomNavButton(
                        id: "stats",
                        currentPageId: currentPageId,
                        icon: "chart.bar.xaxis",
                        label: "Stats",
                        setCurrentPageId: setCurrentPageId
                    )

                    BottomNavButton(
                        id: "library",
                        currentPageId: currentPageId,
                        icon: "music.note.square.stack.fill",
                        label: "Library",
                        setCurrentPageId: setCurrentPageId
                    )

                    BottomNavButton(
                        id: "sessions",
                        currentPageId: currentPageId,
                        icon: "waveform",
                        label: "Sessions",
                        setCurrentPageId: setCurrentPageId
                    )
                }
                .padding(4)
                .glassEffect(.regular, in: Capsule())
                
//                Spacer()
                
//                HStack(spacing: 2) {
//                    BottomNavButton(
//                        id: "search",
//                        currentPageId: currentPageId,
//                        icon: "magnifyingglass",
//                        label: "Search",
//                        setCurrentPageId: setCurrentPageId,
//                        horizontalPadding: 10,
//                        hideLabel: true
//                    )
//                }
//                .padding(4)
//                .background(Color.resonateWhite)
//                .clipShape(Capsule())
//                .overlay(
//                    Capsule()
//                        .stroke(Color.resonatePurple.opacity(0.3), lineWidth: 1)
//                )
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .ignoresSafeArea(edges: .bottom)
    }
}

struct BottomNavButton: View {
    let id: String
    let currentPageId: String
    let icon: String
    let label: String
    let setCurrentPageId: (String) -> Void
    var horizontalPadding: CGFloat = 28
    var verticalPadding: CGFloat = 8
    var hideLabel = false

    let fontSize: CGFloat = 20
    let size: CGFloat = 28
    
    var isActive: Bool {
        currentPageId == id
    }

    var body: some View {
        Button(action: {setCurrentPageId(id)}) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.montserrat(size: fontSize))
                    .fontWeight(.bold)
                    .frame(width: size, height: size) // Centers icon perfectly
                
                if (!hideLabel) {
                    Text(label)
                        .font(.montserrat(size: 10, weight: .bold))
                }
            }
            .padding(.horizontal, horizontalPadding + (hideLabel ? 2 : 0))
            .padding(.vertical, verticalPadding + (hideLabel ? 4 : 0))
        }
        .foregroundStyle(
            isActive ? Color.resonatePurple : Color.resonatePurple.opacity(0.5)
        )
        .background(isActive ? Color.resonatePurple.opacity(0.15) : .clear)
        .contentShape(Capsule())
        .clipShape(Capsule())
    }
}
