//
//  AlbumView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit
import Charts

struct TrackChartView: View {
    let tracks: MusicItemCollection<Track>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tracks")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal, 18)
            
            ScrollView(.horizontal, showsIndicators: false) {
                Chart {
                    ForEach(Array(tracks.enumerated()), id: \.element.id) { index, track in
                        if let count = track.playCount {
                            BarMark(
                                x: .value("Track", track.title),
                                y: .value("Plays", count)
                            )
                        }
                    }
                }
                .frame(width: CGFloat(50 * tracks.count), height: 240)
                .padding(.horizontal, 18)
            }
            .frame(height: 240)
        }
        .padding(.vertical, 20)
        .glassEffect(in: RoundedRectangle(cornerRadius: 16))
    }
}

struct AlbumView: View {
    let album: Album
    
    @State private var tracks: MusicItemCollection<Track> = MusicItemCollection([])
    @State private var selectedTrack: Track? = nil
    @State private var currentSection: Int = 0
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var overlayManager: OverlayManager
    
    @State private var isAddPlaylistsSheetVisible: Bool = false
    @State private var isMenuVisible: Bool = false
    
    @State private var cloudAlbumData: AlbumFromCloud? = nil
    
    var playCount: Int { getTotalPlayCount(tracks) }
    var timePlayed: Double { getTotalTimePlayed(tracks) }
    
    private var adjustedArtworkColor: Color {
        // depend on colorScheme to force recalculation on toggle
        _ = colorScheme
        
        if let bgCG = album.artwork?.backgroundColor,
            let textCG = album.artwork?.primaryTextColor {
            let textColor = UIColor(cgColor: textCG)
            let bgColor = UIColor(cgColor: bgCG)
                
            return idealColor(textColor: textColor, backgroundColor: bgColor)
        }

        return .resonatePurple
    }
    
    private var artworkColor: Color {
        if let cgColor = album.artwork?.backgroundColor {
            return Color(cgColor)
        } else {
            return Color.landingPurple
        }
    }
    
    var body: some View {
        // NavigationStack {
            ScrollView {
                // Album details
                VStack(spacing: 18) {
                    DetailsView(
                        musicItem: album,
                        artwork: album.artwork,
                        title: album.title,
                        artistName: album.artistName,
                        albumTitle: nil,
                        genreNames: album.genreNames,
                        playMusicItem: {playAlbum()},
                        duration: nil,
                        isAppleDigitalMaster: album.isAppleDigitalMaster,
                        audioVariants: album.audioVariants,
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
                        .padding(.bottom, 18)
                        .padding(.leading, 4)

                        if currentSection == 0 {
                            // Album tracks
                            AlbumTracksView (
                                tracks: tracks,
                                adjustedArtworkColor: adjustedArtworkColor,
                                setSelectedTrack: setSelectedTrack
                            )
                            .padding(.horizontal, 20)
                        }
                        else if currentSection == 1 {
                            VStack(alignment: .leading, spacing: 20) {
                                VStack(alignment: .leading, spacing: 18) {
                                    // MARK: - Chart Card
                                    ChartCard(
                                        title: "Play History",
                                        cloudData: cloudAlbumData
                                    )
                                    
                                    // MARK: - Description
                                    Text("This chart shows how your total plays have changed over time. Data updates when content is synced to the cloud.")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                        .padding(.bottom, 10)
                                }
                                
                                if let cloud = cloudAlbumData {
                                    TrendsCard(
                                        history: cloud.history,
                                        unitLabel: "plays"
                                    )
                                }
                                
                                TrackChartView(tracks: tracks)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Stats")
                                        .fontWeight(.bold)
                                        .font(.system(size: 24))
                                    
                                    // Album Stats
                                    AlbumStatsView (
                                        album: album,
                                        playCount: playCount,
                                        timePlayed: timePlayed
                                    )
                                }
                                .padding(.top, 22)
                                .padding(.bottom, 20)
                                .padding(.horizontal, 20)
                                .glassEffect(in: RoundedRectangle(cornerRadius: 16))
                            }
                            .foregroundColor(adjustedArtworkColor)
                            .padding(.horizontal, 20)
                        }

                        ViewSpacer()
                    }
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.resonateWhite.ignoresSafeArea(edges: .bottom))
                    .cornerRadius(28)
                }
            }
            .ignoresSafeArea(edges: .vertical) // extend under status bar
            .background(artworkColor)
//            .sheet(isPresented: $isAddPlaylistsSheetVisible) {
//                NavigationStack {
//                    AddToPlaylist(
//                        // need to update
//                        song: song,
//                        togglePlaylistsSheetVisible: toggleAddPlaylistsSheet,
//                        color: .resonatePurple,
//                        bgColor: .resonateWhite
//                    )
//                }
//                    .foregroundStyle(Color.resonatePurple)
//                    .background(Color.resonateWhite)
//                    .presentationDetents([.medium, .large]) // allows swipe-up expansion
//                    .presentationDragIndicator(.visible)
//            }
            .sheet(isPresented: $isMenuVisible) {
                NavigationStack {
                    CustomMenu (
                        artwork: album.artwork,
                        title: album.title,
                        subtitle: album.artistName,
                        color: adjustedArtworkColor,
                        menuItems: getMenuForAlbum(
                            album,
                            showMessage: { msg in await showMessage(msg) },
                            showError: { msg in await showError(msg) },
                            toggleAddPlaylists: toggleAddPlaylistsSheet
                        )
                    )
                }
                    .background(Color.resonateWhite)
                    .presentationDetents([.height(450)]) // allows swipe-up expansion
                    .presentationDragIndicator(.visible)
            }
            .task {
                await getAlbumFromRealtimeDatabase()
            }
            .onAppear {
                Task {
                    if album.tracks == nil {
                        do {
                            let fullAlbum = try await album.with([.tracks])
                            tracks = fullAlbum.tracks ?? MusicItemCollection([])

                        } catch {
                            overlayManager.showError("Failed to load tracks")
                        }
                    }
                }
            }
        // }
    }
    
    func toggleMenuSheet() {
        isMenuVisible = !isMenuVisible
    }
    
    func toggleAddPlaylistsSheet() {
        isAddPlaylistsSheetVisible = !isAddPlaylistsSheetVisible
    }

    func setCurrentSection(_ index: Int) {
        currentSection = index
    }

    func setSelectedTrack(_ track: Track) {
        selectedTrack = track
    }
    
    func playAlbum() {
        Task {
            await playItem(
                album,
                clearExistingItems: true
            ) { error in
                Task { await showError("Playback failed: \(error.localizedDescription)") }
            }
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Gets the album from the Firebase Realtime Database
    func getAlbumFromRealtimeDatabase() async {
        guard let userID = authManager.userID else {
            Task {
                await showError("Not logged in")
            }
            return
        }
        
        cloudAlbumData = await getItemFromDatabase(
            id: album.id,
            userID: userID,
            type: "albums",
            showError: showError
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

func idealColor (
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

func getTotalPlayCount(_ tracks: MusicItemCollection<Track>) -> Int {
    return tracks.reduce(0) { $0 + ($1.playCount ?? 0) }
}

func getTotalTimePlayed(_ tracks: MusicItemCollection<Track>) -> Double {
    return tracks.reduce(0) { total, track in
        if let duration = track.duration {
            return total + Double(track.playCount ?? 0) * duration
        }
        return total
    }
}

func addAlbumToPlayNext(
    _ album: Album,
    showMessage: @escaping (String) async -> Void,
    showError: @escaping (String) async -> Void
) {
    Task {
        await playItem(album, playImmediately: false) { error in
            Task { await showError("Playback failed: \(error.localizedDescription)") }
        }
        
        await showMessage("Playing next: " + album.title)
    }
}

func addAlbumToQueue(
    _ album: Album,
    showMessage: @escaping (String) async -> Void,
    showError: @escaping (String) async -> Void
) {
    Task {
        await playItem(album, playImmediately: false, addToEndOfQueue: true) { error in
            Task { await showError("Playback failed: \(error.localizedDescription)") }
        }
        
        await showMessage("Added to queue: " + album.title)
    }
}
