//
//  ArtistView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct Title: View {
    let text: String

    var body: some View {
        HStack() {
            Text(text)
                .font(.system(size: 24))
                .fontWeight(.bold)
            
            Spacer()
        }
    }
}

struct ArtistView: View {
    let artist: Artist
    
    @EnvironmentObject var overlayManager: OverlayManager

    @State private var detailedArtist: Artist?
    
    @State private var appleMusicErrorMessage: String?
    @State private var libraryErrorMessage: String?
    @State private var errorMessage: String?
    
    // Initialise albums and tracks
    @State private var librarySongs: [Song] = []
    @State private var tracks: MusicItemCollection<Track> = []

    @State private var isAppleMusicDataAvailable = true
    @State private var isLoading = true

    @State private var selectedSong: Song?
    @State private var selectedAlbum: Album?
    @State private var currentSection = 0
    
    @State private var cloudArtistData: ArtistFromCloud?

    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthManager

    var playCount: Int { getTotalPlayCount(tracks) }
    var timePlayed: Double { getTotalTimePlayed(tracks) }
    
    private var artworkColor: Color {
        if let cgColor = artist.artwork?.backgroundColor {
            return Color(cgColor)
        } else {
            return Color.landingPurple
        }
    }
    
    private var primaryColor: Color {
        if let cgColor = artist.artwork?.primaryTextColor {
            return Color(cgColor)
        } else {
            return .white
        }
    }

    private var adjustedArtworkColor: Color {
        // depend on colorScheme to force recalculation on toggle
        _ = colorScheme
        
        if let bgCG = detailedArtist?.artwork?.backgroundColor ??  artist.artwork?.backgroundColor,
            let textCG = detailedArtist?.artwork?.primaryTextColor ?? artist.artwork?.primaryTextColor {
            let textColor = UIColor(cgColor: textCG)
            let bgColor = UIColor(cgColor: bgCG)
                
            return idealColor(textColor: textColor, backgroundColor: bgColor)
        }

        return .resonatePurple
    }
    
    var body: some View {
        // NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ArtistDetailsView(
                        artist: artist,
                        artwork: detailedArtist?.artwork ?? artist.artwork,
                        name: detailedArtist?.name ?? artist.name,
                        text: detailedArtist?.editorialNotes?.short ?? "No description available",
                        playSong: {playSong()}
                    )

                    VStack {
                        if (isLoading) {
                            ClassicLoadingView(text: "Loading artist data")
                        } else {
                            HStack {
                                CustomPicker(
                                    color: adjustedArtworkColor,
                                    currentSection: currentSection,
                                    setCurrentSection: setCurrentSection,
                                    options: isAppleMusicDataAvailable ? [
                                        "Your Library",
                                        "Stats",
                                        "Apple Music"
                                    ] : [
                                        "Your Library",
                                        "Stats"
                                    ]
                                )
                            }
                            .padding(.top, 6)
                            .padding(.bottom, 4)
                            
                            VStack {
                                if currentSection == 0 {
                                    FromLibraryView(
                                        songs: librarySongs,
                                        adjustedArtworkColor: adjustedArtworkColor,
                                        errorMessage: libraryErrorMessage,
                                        setSelectedSong: setSelectedSong
                                    )
                                    .padding(.horizontal)
                                }
                                else if currentSection == 1 {
                                    VStack(alignment: .leading, spacing: 20) {
                                        VStack(alignment: .leading, spacing: 18) {
                                            // MARK: - Chart Card
                                            ChartCard(
                                                title: "Play History",
                                                cloudData: cloudArtistData,
                                                color: adjustedArtworkColor
                                            )
                                            
                                            // MARK: - Description
                                            Text("This chart shows how your total plays have changed over time. Data updates when content is synced to the cloud.")
                                                .font(.montserrat(size: 12))
                                                .foregroundStyle(.secondary)
                                                .padding(.horizontal)
                                                .padding(.bottom, 10)
                                        }
                                        
                                        if let cloud = cloudArtistData {
                                            TrendsCard(
                                                history: cloud.history,
                                                unitLabel: "plays"
                                            )
                                            .padding(.horizontal)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 12) {
                                            SectionHeader(
                                                title: "Stats",
                                                subtitle: "See your artist stats in a glance",
                                                hasLeadingPadding: false
                                            )
                                            
                                            ArtistStatsView(
                                                artist: artist,
                                                librarySongs: librarySongs
                                            )
                                        }
                                        .padding(.horizontal)
                                    }
                                    .foregroundColor(adjustedArtworkColor)
                                }
                                else if currentSection == 2 {
                                    FromAppleMusicView(
                                        detailedArtist: detailedArtist,
                                        adjustedArtworkColor: adjustedArtworkColor,
                                        errorMessage: appleMusicErrorMessage,
                                        setSelectedSong: setSelectedSong,
                                        setSelectedAlbum: setSelectedAlbum
                                    )
                                }
                            }
                
                            ViewSpacer()
                        }
                    }
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.resonateWhite.ignoresSafeArea(edges: .bottom))
                    .cornerRadius(20)
                }
            }
            .background(artworkColor)
            .navigationDestination(item: $selectedAlbum) { album in
                AlbumView(album: album)
            }
            .navigationDestination(item: $selectedSong) { song in
                SongView(song: song)
            }
            .task {
                do {
                    if let fullArtist = try await fetchDetailedArtist(for: artist) {
                        await MainActor.run {
                            detailedArtist = fullArtist
                            appleMusicErrorMessage = nil
                        }
                    } else {
                        await MainActor.run {
                            appleMusicErrorMessage = "Artist not found in catalog"
                            isAppleMusicDataAvailable = false
                        }
                    }
                    
                    let songs = try await getSongsFromLibrary(for: artist)
                    await MainActor.run {
                        librarySongs = songs
                        libraryErrorMessage = songs.isEmpty ? "Songs not found in library" : nil
                    }
                    
                    await getArtistFromRealtimeDatabase()

                    // Change state once content is loaded
                    isLoading = false
                } catch {
                    await MainActor.run {
                        errorMessage = "Fetch artist failed: \(error.localizedDescription)"
                    }
                }
            }
            .ignoresSafeArea(edges: .vertical) // extend under status bar
        // }
        // .ignoresSafeArea(edges: .top)
    }
    
    /// Gets the artist from the Firebase Realtime Database
    func getArtistFromRealtimeDatabase() async {
        guard let userID = authManager.userID else {
            Task {
                await showError("Not logged in")
            }
            return
        }
        
        cloudArtistData = await getItemFromDatabase(
            id: artist.id,
            userID: userID,
            type: "artists",
            showError: showError
        )
    }

    func setSelectedSong(_ toSet: Song) {
        selectedSong = toSet
    }

    func setSelectedAlbum(_ toSet: Album) {
        selectedAlbum = toSet
    }

    func setCurrentSection(_ index: Int) {
        currentSection = index
    }

    func playSong() {
//        Task {
//            do {
//                let player = SystemMusicPlayer.shared
//                // player.queue = [song] // set queue with this song
//                // try await player.play() // must be awaited
//            } catch {
//                await MainActor.run {
//                    errorMessage = "Playback failed: \(error.localizedDescription)"
//                }
//            }
//        }
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

func fetchDetailedArtist(for artist: Artist) async throws -> Artist? {
    // First, resolve catalog artist by name
    guard let catalogArtist = try await resolveCatalogArtist(from: artist) else { return nil }

    // Then fetch all properties in one go
    var request = MusicCatalogResourceRequest<Artist>(matching: \.id, equalTo: catalogArtist.id)
    request.properties = [.topSongs, .latestRelease, .fullAlbums] // fetch everything upfront

    let response = try await request.response()
    return response.items.first
}

func resolveCatalogArtist(from libraryArtist: Artist) async throws -> Artist? {
    // search by name
    var search = MusicCatalogSearchRequest(term: libraryArtist.name, types: [Artist.self])
    search.limit = 1
    
    let searchResponse = try await search.response()
    if let firstResponse = searchResponse.artists.first {
        if (firstResponse.name == libraryArtist.name) {
            return firstResponse
        }
    }
    
    return nil
}

func getSongsFromLibrary(for artist: Artist) async throws -> [Song] {
    // Fetch songs from the user's library and filter locally by artist name to avoid
    // initializer/enum differences across MusicKit versions.
    let request = MusicLibraryRequest<Song>()
    let response = try await request.response()

    let targetName = artist.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return response.items.filter { song in
        song.artistName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == targetName
    }
}

func getAlbumsFromLibrary(for artist: Artist) async throws -> [Album] {
    // Fetch albums from the user's library and filter locally by artist name to avoid
    // initializer/enum differences across MusicKit versions.
    let request = MusicLibraryRequest<Album>()
    let response = try await request.response()

    let targetName = artist.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return response.items.filter { album in
        album.artistName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == targetName
    }
}

func fetchTracksFromAlbums(_ albums: [Album]) async throws -> [Track] {
    var allTracks: [Track] = []
    
    for album in albums {
        // Fetch album with tracks using .with()
        let fullAlbum = try await album.with([.tracks])
        
        if let tracks = fullAlbum.tracks {
            allTracks.append(contentsOf: tracks)
        }
    }
    
    return allTracks
}

func getTotalPlays(artist: Artist) async -> Int {
    do {
        let albums = try await getAlbumsFromLibrary(for: artist)
        guard !albums.isEmpty else { return 0 }

        var allTracks: [Track] = []

        await withTaskGroup(of: [Track].self) { group in
            for album in albums {
                group.addTask {
                    do {
                        let fullAlbum = try await album.with([.tracks])
                        return fullAlbum.tracks.map { Array($0) } ?? []
                    } catch {
                        return []
                    }
                }
            }

            for await fetched in group {
                allTracks.append(contentsOf: fetched)
            }
        }

        return getTotalPlayCount(MusicItemCollection(allTracks))
    } catch {
        return 0
    }
}
