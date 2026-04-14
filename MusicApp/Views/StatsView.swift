//
//  StatsView.swift
//  TrackSense
//
//  Created by Russal Arya on 20/9/2025.
//

import SwiftUI
import MusicKit
import FirebaseFirestore
import FirebaseDatabase

struct AlbumStat: Identifiable, Equatable {
    let id = UUID()
    let album: Album
    let totalPlayCount: Int
    let timePlayed: Int
    
    static func == (lhs: AlbumStat, rhs: AlbumStat) -> Bool {
        lhs.id == rhs.id
    }
}

struct ArtistStat: Identifiable, Equatable {
    let id = UUID()
    let artist: Artist
    let totalPlayCount: Int
    let timePlayed: Int
    
    static func == (lhs: ArtistStat, rhs: ArtistStat) -> Bool {
        lhs.id == rhs.id
    }
}

func sanitizeId(_ id: String) -> String {
    return id.replacingOccurrences(of: ".", with: "_")
}

func sanitizeDate(_ date: Date) -> String {
    return date.formatted(.iso8601.year().month().day())
}

/// Sets the Realtime Database path using the parameters
/// - Parameters:
///   - userID: the current User's user ID
///   - type: type of Music Item, can be song, album or artist
///   - id: ID of Music Item
/// - Returns: the path as a string
func setPath(userID: String, type: String, id: String) -> String {
    return "users/\(userID)/\(type)/\(id)"
}

/// Fetch library played hours from Realtime Database
func getStatFromCloud(
    userID: String,
    dataType: String,
    errorMessage: String,
    showError: @escaping (String) async -> Void
) async -> StatFromCloud? {
    let path = "users/\(userID)/\(dataType)"

    do {
        let snapshot = try await Database.database().reference()
            .child(path)
            .getData()

        guard snapshot.exists() else {
            await showError("Data not found in Cloud")
            return nil
        }
        
        guard let item = StatFromCloud(snapshot: snapshot) else {
            await showError("Invalid format")
            return nil
        }

        return item
    } catch {
        await showError(errorMessage)
        return nil
    }
}

func getSortingMenu(
    isShowingPlays: Bool,
    setShowingPlays: @escaping (Bool) -> Void
) -> [[MenuItem]] {
    return [
        [
            MenuItem(
                icon: isShowingPlays ? "checkmark" : nil,
                label: "Plays",
                action: {setShowingPlays(true)}
            ),
            MenuItem(
                icon: isShowingPlays ? nil : "checkmark",
                label: "Minutes",
                action: {setShowingPlays(false)}
            )
        ]
    ]
}

struct TopStatsToggleItem: View {
    let displayItem: AnyView
    let onSeeAll: () -> Void
    
    var body: some View {
        VStack(spacing: 18) {
            displayItem
                .padding(.horizontal)
            
            StandardButton(
                label: "See all",
                action: onSeeAll
            )
            .padding(.horizontal)
        }
    }
}

struct StatsView: View {
    let userToken: String
    
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var overlayManager: OverlayManager
    @EnvironmentObject var songLibraryManager: SongLibraryManager
    
    @State private var topSongs: MusicItemCollection<Song> = []
    @State private var topAlbums: MusicItemCollection<Album> = []
    @State private var albumStats: [AlbumStat] = []
    @State private var topArtists: MusicItemCollection<Artist> = []
    @State private var artistStats: [ArtistStat] = []
    @State private var playlists: MusicItemCollection<Playlist> = []
    
    @State private var libraryPlayedHours: Int?
    @State private var totalPlays: Int = 0
    
    @State private var selectedSong: Song?
    @State private var selectedAlbum: Album?
    @State private var selectedArtist: Artist?
    @State private var selectedTopStat: Int = 0

    @State private var buttonTapped: String?
    
    @State private var isSyncing = false
    @State private var syncProgress: Double = 0    // 0.0 → 1.0
    @State private var syncStepDescription: String = ""
    
    @State private var isLibraryHoursGraphVisible = false
    @State private var isTotalPlaysSheetVisible = false
    
    @AppStorage("lastStatsSync") var lastStatsSync: Date?

    @State private var cloudLibraryPlayedHoursData: StatFromCloud?
    @State private var cloudTotalPlayedData: StatFromCloud?
    
    @State private var currentSection = 0
    
    @State private var hasLoaded = false
    
    @State private var isShowingPlays = true
    
    let limit = 5

    func toggleLibraryHoursSheet() {
        isLibraryHoursGraphVisible = !isLibraryHoursGraphVisible
    }
    
    func toggleTotalPlaysSheet() {
        isTotalPlaysSheetVisible = !isTotalPlaysSheetVisible
    }
    
    func setShowingPlays(value: Bool) {
        isShowingPlays = value
    }
    
    let margin: CGFloat = 20
    
    func setCurrentSection(_ index: Int) {
        currentSection = index
    }
    
    // To prevent cloud sync on every reboot
    @State private var inProductionMode = true
    
    var body: some View {
        NavigationStack {
            ScrollView() {
                VStack(spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            PageHeader(text: "Stats")

                            Text("Last synced: \(lastStatsSync?.formatted(date: .abbreviated, time: .shortened) ?? "never")")
                                .font(.montserrat(size: 14, weight: .medium))
                                .foregroundStyle(Color.customLightPurple)
                        }
                        Spacer()
                        Button(action: {
                            Task { await syncToCloud() }
                        }) {
                            HStack(spacing: 8) {
                                if isSyncing {
                                    ProgressView()
                                    Text("\(Int(syncProgress * 100))%")
                                        .monospacedDigit()
                                        .font(.montserrat(size: 16, weight: .semibold))

//                                    Text(syncStepDescription)
//                                        .font(.montserrat(size: 14, weight: .medium))
//                                        .foregroundColor(.secondary)
                                } else {
                                    Image(systemName: "arrow.clockwise.icloud")
                                        .font(.montserrat(size: 20))
                                    Text("Sync")
                                        .font(.montserrat(size: 16, weight: .bold))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .foregroundColor(isSyncing ? .resonateLightPurple : .resonatePurple)
                            .overlay(
                                Capsule()
                                    .stroke(Color.resonatePurple.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.top)
                        }
                        .disabled(isSyncing)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        TabView(selection: $selectedTopStat) {
                            LibraryHoursStat(
                                hours: libraryPlayedHours,
                                toggleLibraryHoursSheet: toggleLibraryHoursSheet
                            )
                            .padding(.horizontal)
                            .tag(0)
                            
                            TotalPlaysStat(
                                totalPlays: totalPlays,
                                toggleTotalPlaysSheet: toggleTotalPlaysSheet
                            )
                            .padding(.horizontal)
                            .tag(1)
                        }
                        .frame(height: 140)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        
                        CustomDots(length: 2, selectedDot: selectedTopStat)
                        .padding(.top, 4)
                    }
                    
                    VStack(spacing: 8) {
                        // Top Stats
                        HStack(alignment: .bottom) {
                            SectionHeader(
                                title: "Top Stats",
                                subtitle: "What you have been listening to",
                                margin: margin
                            )
                            
                            Menu {
                                generateMenu(
                                    getSortingMenu(
                                        isShowingPlays: isShowingPlays,
                                        setShowingPlays: setShowingPlays
                                    )
                                )
                            } label: {
                                Image(systemName: "eye")
                                    .fontWeight(.bold)
                                    .font(.montserrat(size: 16))
                                    .foregroundColor(.resonatePurple)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(Color.resonatePurple.opacity(0.12))
                                    )
                                    .padding(.bottom, 6)
                            }
                        }
                        .padding(.trailing)
                        
                        CustomPicker(
                            color: .resonatePurple,
                            currentSection: currentSection,
                            setCurrentSection: setCurrentSection,
                            options: [
                                "Songs",
                                "Albums",
                                "Artists"
                            ]
                        )
                        .padding(.bottom, 6)
                        
                        TabView(selection: $currentSection) {
                            TopStatsToggleItem(
                                displayItem: AnyView(
                                    DisplayTopSongs(
                                        songs: Array(topSongs.prefix(limit)),
                                        setSelectedSong: setSelectedSong,
                                        isShowingPlays: isShowingPlays
                                    )
                                ),
                                onSeeAll: { buttonTapped = "songs" }
                            )
                            .tag(0)
                            
                            TopStatsToggleItem(
                                displayItem: AnyView(
                                    DisplayTopAlbums(
                                        albumStats: Array(albumStats.prefix(limit)),
                                        setSelectedAlbum: setSelectedAlbum,
                                        isShowingPlays: isShowingPlays
                                    )
                                ),
                                onSeeAll: { buttonTapped = "albums" }
                            )
                            .tag(1)
                            
                            TopStatsToggleItem(
                                displayItem: AnyView(
                                    DisplayTopArtists(
                                        artistStats: Array(artistStats.prefix(limit)),
                                        setSelectedArtist: setSelectedArtist,
                                        isShowingPlays: isShowingPlays
                                    )
                                ),
                                onSeeAll: { buttonTapped = "artists" }
                            )
                            .tag(2)
                        }
                        .frame(height: 450)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                    
                    // Library Stats
                    LibraryStats(
                        songs: songLibraryManager.songs,
                        albumStats: albumStats,
                        artistStats: artistStats,
                        playlists: playlists
                    )
                }
                
                ViewSpacer()
            }
            .background(Color.resonateWhite)
            .refreshable {
                await refreshStats()
                
                if inProductionMode {
                    await syncToCloud()
                }
            }
        }
        .sheet(isPresented: $isLibraryHoursGraphVisible) {
            LibraryHoursSheet(cloudData: cloudLibraryPlayedHoursData)
        }
        .sheet(isPresented: $isTotalPlaysSheetVisible) {
            TotalPlaysSheet(cloudData: cloudTotalPlayedData)
        }
        .navigationDestination(item: $selectedSong) { SongView(song: $0) }
        .navigationDestination(item: $selectedAlbum) { AlbumView(album: $0) }
        .navigationDestination(item: $selectedArtist) { ArtistView(artist: $0) }
        .navigationDestination(item: $buttonTapped) { section in
            switch section {
            case "songs":
                TopSongsView(songs: Array(topSongs))
            case "albums":
                TopAlbumsView(albumStats: albumStats)
            default:
                // BUG: have to fix selected artists being handled inside the view instead of being passed in as an argument
                TopArtistsView(artistStats: artistStats, setSelectedArtist: setSelectedArtist)
            }
        }
        .task {
            guard !hasLoaded else { return }
            hasLoaded = true
            await refreshStats()
            
            if inProductionMode {
                await syncToCloud()
            }
        }
    }
    
    @MainActor
    private func refreshStats() async {
        // Trigger manager refresh
        await songLibraryManager.refreshLibrary()

        // Now recompute everything from fresh data
        await calculateLibraryPlayedHoursAndTotalPlays()

        await fetchLibraryPlayedHoursFromRealtimeDatabase()
        await fetchTotalPlaysFromRealtimeDatabase()

        await fetchTopSongs()
        await fetchTopAlbums()
        await fetchTopArtists()
        await fetchLibraryPlaylists()
    }

    @MainActor
    private func syncToCloud() async {
        guard !isSyncing else { return }

        isSyncing = true
        syncProgress = 0
        syncStepDescription = "Starting…"

        defer {
            isSyncing = false
            syncStepDescription = ""
            syncProgress = 0
        }

        // Ensure we have fresh local library data and derived stats BEFORE uploading.
        // This does NOT read from cloud and does NOT run the full refresh pipeline.
        await songLibraryManager.refreshLibrary()
        await calculateLibraryPlayedHoursAndTotalPlays()
        await fetchTopAlbums()
        await fetchTopArtists()

        let totalSteps = 5.0
        var currentStep = 0.0

        func advance(_ desc: String) {
            currentStep += 1
            syncStepDescription = desc
            withAnimation(.easeInOut(duration: 0.2)) {
                syncProgress = currentStep / totalSteps
            }
        }

        // 1 — Hours + Total Plays
        advance("Library Hours, Total Plays")
        await updateLibraryPlayedHoursAndTotalPlaysToRealtimeDatabase()

        // 2 — Library counts
        advance("Library Stats")
        await updateLibraryStatsToRealtimeDatabase()

        // 3 — Songs
        advance("Songs")
        await uploadSongsToRealtimeDatabase(songLibraryManager.songs)

        // 4 — Albums
        advance("Albums")
        await uploadAlbumsToRealtimeDatabase(albumStats)

        // 5 — Artists
        advance("Artists")
        await uploadArtistsToRealtimeDatabase(artistStats)

        lastStatsSync = Date.now
    }

    private func calculateLibraryPlayedHoursAndTotalPlays() async {
        var durationTotal: Double = 0
        var playsTotal: Int = 0
        
        for song in songLibraryManager.songs {
            if let playCount = song.playCount, playCount > 0 {
                playsTotal += playCount
            }
            if let duration = song.duration {
                durationTotal += Double(song.playCount ?? 0) * duration
            }
        }
        
        libraryPlayedHours = Int((durationTotal / 60) / 60)
        totalPlays = playsTotal
    }
    
    /// Updates the library played hours to Firebase Realtime Database
    private func updateLibraryPlayedHoursAndTotalPlaysToRealtimeDatabase() async {
        // Get user ID
        guard let userID = authManager.userID else { return }
        
        let ref = Database.database().reference()
        let dateKey = sanitizeDate(Date.now)
        
        let updates: [String: Any] = [
            "users/\(userID)/libraryPlayedHours/value": libraryPlayedHours ?? 0,
            "users/\(userID)/libraryPlayedHours/history/\(dateKey)/value": libraryPlayedHours ?? 0,
            "users/\(userID)/totalPlays/value": totalPlays,
            "users/\(userID)/totalPlays/history/\(dateKey)/value": totalPlays
        ]
        
        do {
            try await ref.updateChildValues(updates)
            await MainActor.run { overlayManager.showOverlay("Updated library play hours and total plays") }
        } catch {
            await MainActor.run { overlayManager.showError("Failed to upload library hours and total plays: \(error.localizedDescription)") }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { overlayManager.showOverlay(nil) }
        }
    }

    /// Updates the library stats to Firebase Realtime Database
    private func updateLibraryStatsToRealtimeDatabase() async {
        // Get user ID
        guard let userID = authManager.userID else { return }
        
        let ref = Database.database().reference()
        let dateKey = sanitizeDate(Date.now)
        
        let songs = songLibraryManager.songs
        
        let updates: [String: Any] = [
            "users/\(userID)/songsCount/value": songs.count,
            "users/\(userID)/songsCount/history/\(dateKey)/value": songs.count,
            "users/\(userID)/albumsCount/value": albumStats.count,
            "users/\(userID)/albumsCount/history/\(dateKey)/value": albumStats.count,
            "users/\(userID)/artistsCount/value": artistStats.count,
            "users/\(userID)/artistsCount/history/\(dateKey)/value": artistStats.count
        ]
        
        do {
            try await ref.updateChildValues(updates)
            await MainActor.run { overlayManager.showOverlay("Updated library stats") }
        } catch {
            await MainActor.run { overlayManager.showError("Failed to upload library stats: \(error.localizedDescription)") }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { overlayManager.showOverlay(nil) }
            withAnimation { overlayManager.showError(nil) }
        }
    }

    /// Fetches the library played hours from the Firebase Realtime Database
    func fetchLibraryPlayedHoursFromRealtimeDatabase() async {
        guard let userID = authManager.userID else {
            Task {
                await showError("Not logged in")
            }
            return
        }
        
        cloudLibraryPlayedHoursData = await getStatFromCloud(
            userID: userID,
            dataType: "libraryPlayedHours",
            errorMessage: "Failed to fetch library hours from Cloud",
            showError: showError
        )
    }
    
    /// Fetches the library played hours from the Firebase Realtime Database
    func fetchTotalPlaysFromRealtimeDatabase() async {
        guard let userID = authManager.userID else {
            Task {
                await showError("Not logged in")
            }
            return
        }
        
        cloudTotalPlayedData = await getStatFromCloud(
            userID: userID,
            dataType: "totalPlays",
            errorMessage: "Failed to fetch total plays from Cloud",
            showError: showError
        )
    }
    
    private func fetchTopSongs() async {
        let sorted = songLibraryManager.songs.sorted {
            if isShowingPlays {
                return ($0.playCount ?? 0) > ($1.playCount ?? 0)
            } else {
                let l = ($0.playCount ?? 0) * Int($0.duration ?? 0)
                let r = ($1.playCount ?? 0) * Int($1.duration ?? 0)
                return l > r
            }
        }
        
        topSongs = MusicItemCollection(sorted)
    }

    private func fetchTopAlbums() async {
        do {
            var albumPlayCounts: [String: Int] = [:]
            var albumTimePlayed: [String: Int] = [:]

            for song in songLibraryManager.songs {
                guard let albumTitle = song.albumTitle, !albumTitle.isEmpty else { continue }
                if let playCount = song.playCount {
                    if let duration = song.duration {
                        albumPlayCounts[albumTitle, default: 0] += playCount
                        albumTimePlayed[albumTitle, default: 0] += Int(getMinutesPlayed(playCount: playCount, duration: duration))
                    }
                }
            }

            let albumRequest = MusicLibraryRequest<Album>()
            let albumResponse = try await albumRequest.response()
            let albumsArray = Array(albumResponse.items)

            let sortedAlbums = albumsArray.sorted {
                if isShowingPlays {
                    (albumPlayCounts[$0.title] ?? 0) > (albumPlayCounts[$1.title] ?? 0)
                } else {
                    (albumTimePlayed[$0.title] ?? 0) > (albumTimePlayed[$1.title] ?? 0)
                }
            }

            // Create display data
            albumStats = sortedAlbums.map { album in
                AlbumStat(
                    album: album,
                    totalPlayCount: albumPlayCounts[album.title] ?? 0,
                    timePlayed: albumTimePlayed[album.title] ?? 0
                )
            }

            topAlbums = MusicItemCollection(sortedAlbums)
        } catch {
            await showError(error.localizedDescription)
        }
    }

    /// Get top artists from MusicKit data
    private func fetchTopArtists() async {
        do {
            // Aggregate total plays by artist name
            var artistPlayCounts: [String: Int] = [:]
            var artistTimePlayed: [String: Int] = [:]

            for song in songLibraryManager.songs {
                let artistName = song.artistName
                guard !artistName.isEmpty else { continue }
                if let playCount = song.playCount {
                    if let duration = song.duration {
                        artistPlayCounts[artistName, default: 0] += playCount
                        artistTimePlayed[artistName, default: 0] += Int(getMinutesPlayed(playCount: playCount, duration: duration))
                    }
                }
            }

            // Fetch all artists
            let artistRequest = MusicLibraryRequest<Artist>()
            let artistResponse = try await artistRequest.response()
            let artistsArray = Array(artistResponse.items)

            // Map artists to ArtistStat with total play counts
            let artistStatsUnsorted = artistsArray.map { artist -> ArtistStat in
                ArtistStat(
                    artist: artist,
                    totalPlayCount: artistPlayCounts[artist.name] ?? 0,
                    timePlayed: artistTimePlayed[artist.name] ?? 0
                )
            }

            // Sort by total play count / minutes descending
            artistStats = artistStatsUnsorted.sorted {
                if isShowingPlays {
                    $0.totalPlayCount > $1.totalPlayCount
                } else {
                    $0.timePlayed > $1.timePlayed
                }
            }
        } catch {
            await showError(error.localizedDescription)
        }
    }
    
    /// Uploads the songs to the Firebase Realtime Database
    private func uploadSongsToRealtimeDatabase(_ songs: [Song]) async {
        guard let userID = authManager.userID else { return }
        let ref = Database.database().reference()
        let dateKey = sanitizeDate(Date.now)

        var updates: [String: Any] = [:]

        for song in songs {
            guard let playCount = song.playCount else { continue }
            
            let safeSongId = sanitizeId(song.id.rawValue)

            let songPath = setPath(userID: userID, type: "songs", id: safeSongId)
            
            updates["\(songPath)/title"] = song.title
            updates["\(songPath)/artistName"] = song.artistName
            updates["\(songPath)/albumTitle"] = song.albumTitle ?? ""
            updates["\(songPath)/plays"] = playCount
            updates["\(songPath)/lastPlayedDate"] = song.lastPlayedDate?.formatted() ?? ""
            updates["\(songPath)/history/\(dateKey)/plays"] = playCount
        }

        do {
            try await ref.updateChildValues(updates)
            await MainActor.run { overlayManager.showOverlay("Updated \(songs.count) songs") }
        } catch {
            await MainActor.run { overlayManager.showError("Failed to update songs: \(error.localizedDescription)") }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { overlayManager.showOverlay(nil) }
            withAnimation { overlayManager.showError(nil) }
        }
    }
    
    /// Uploads the albums to the Firebase Realtime Database
    private func uploadAlbumsToRealtimeDatabase(_ albums: [AlbumStat]) async {
        guard let userID = authManager.userID else { return }
        let ref = Database.database().reference()
        let dateKey = sanitizeDate(Date.now)

        var updates: [String: Any] = [:]

        for album in albums {
            let playCount = album.totalPlayCount
            let minutes = album.timePlayed
            
            let safeAlbumId = sanitizeId(album.album.id.rawValue)

            let albumPath = "users/\(userID)/albums/\(safeAlbumId)"
            updates["\(albumPath)/title"] = album.album.title
            updates["\(albumPath)/artistName"] = album.album.artistName
            updates["\(albumPath)/totalPlays"] = playCount
            updates["\(albumPath)/minutes"] = minutes
            updates["\(albumPath)/history/\(dateKey)/totalPlays"] = playCount
            updates["\(albumPath)/history/\(dateKey)/minutes"] = minutes
        }

        do {
            try await ref.updateChildValues(updates)
            await MainActor.run { overlayManager.showOverlay("Updated \(albums.count) albums") }
        } catch {
            await MainActor.run { overlayManager.showError("Failed to update albums: \(error.localizedDescription)") }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { overlayManager.showOverlay(nil) }
            withAnimation { overlayManager.showError(nil) }
        }
    }
    
    /// Uploads the artists to the Firebase Realtime Database
    private func uploadArtistsToRealtimeDatabase(_ artists: [ArtistStat]) async {
        guard let userID = authManager.userID else { return }
        let ref = Database.database().reference()
        let dateKey = sanitizeDate(Date.now)

        var updates: [String: Any] = [:]

        for artist in artists {
            let playCount = artist.totalPlayCount
            let minutes = artist.timePlayed
            
            let safeArtistId = sanitizeId(artist.artist.id.rawValue)

            let artistPath = "users/\(userID)/artists/\(safeArtistId)"
            updates["\(artistPath)/name"] = artist.artist.name
            updates["\(artistPath)/totalPlays"] = playCount
            updates["\(artistPath)/minutes"] = minutes
            updates["\(artistPath)/history/\(dateKey)/totalPlays"] = playCount
            updates["\(artistPath)/history/\(dateKey)/minutes"] = minutes
        }

        do {
            try await ref.updateChildValues(updates)
            await MainActor.run { overlayManager.showOverlay("Updated \(artists.count) artists") }
        } catch {
            await MainActor.run { overlayManager.showError("Failed to update artists: \(error.localizedDescription)") }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { overlayManager.showOverlay(nil) }
            withAnimation { overlayManager.showError(nil) }
        }
    }

    func fetchLibraryPlaylists() async {
        do {
            // Fetch user's library playlists
            let request = MusicLibraryRequest<Playlist>()
            let response = try await request.response()

            // Sort by lastModifiedDate descending (newest first). Missing dates go to the end.
            let sorted = response.items.sorted { lhs, rhs in
                let l = lhs.lastModifiedDate
                let r = rhs.lastModifiedDate
                switch (l, r) {
                case let (.some(ld), .some(rd)):
                    return ld > rd
                case (nil, .some):
                    // place nil after any real date
                    return false
                case (.some, nil):
                    // place real date before nil
                    return true
                case (nil, nil):
                    return false
                }
            }

            await MainActor.run {
                // Wrap back into MusicItemCollection
                playlists = MusicItemCollection(sorted)
            }
        } catch {
            await MainActor.run {
                overlayManager.showError("Failed to fetch playlists: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { overlayManager.showError(nil) }
            }
        }
    }

    
    func setSelectedSong(song: Song) {
        selectedSong = song
    }
    
    func setSelectedAlbum(album: Album) {
        selectedAlbum = album
    }
    
    func setSelectedArtist(artist: Artist) {
        selectedArtist = artist
    }
    
    func showError(_ message: String) async {
        await displayMessage(message, setMessage: overlayManager.showError)
    }
}

struct CustomDots: View {
    let length: Int
    var selectedDot: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(0..<length), id: \.self) { idx in
                Circle()
                    .fill(idx == selectedDot ? Color.resonatePurple : Color.gray.opacity(0.35))
                    .frame(width: idx == selectedDot ? 10 : 7, height: idx == selectedDot ? 10 : 7)
                    .scaleEffect(idx == selectedDot ? 1.05 : 1.0)
                    .animation(.easeOut(duration: 0.18), value: selectedDot)
            }
        }
    }
}

