//
//  HomeView.swift
//  Resonate
//
//  Created by Russal Arya on 20/9/2025.
//

import SwiftUI
import MusicKit

struct PageHeader: View {
    let text: String
    
    var body: some View {
        HStack() {
            Text(text)
                .font(.montserrat(size: 32, weight: .bold))
                .padding(.top, 8)
            
            Spacer()
        }
    }
}

struct DisplayPlaylistsInGrid: View {
    let playlists: MusicItemCollection<Playlist>
    var errorMessage: String?
    let setSelectedPlaylist: (Playlist) -> Void
    let limit: Int
    let margin: CGFloat

    var body: some View {
        if playlists.isEmpty {
            // Loading state
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5) // make it bigger if you want
                    .padding(.top, 20)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }
            }
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 8) {
                    ForEach(playlists.prefix(limit), id: \.id) { playlist in
                        VStack {
                            LargeMusicItemBlock(
                                artwork: playlist.artwork,
                                title: playlist.name,
                                artistName: nil,
                                playCount: nil,
                                size: 160
                            ) {
                                setSelectedPlaylist(playlist)
                            }                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct DisplaySongsInGrid: View {
    let songs: MusicItemCollection<Song>
    var errorMessage: String?
    let setSelectedSong: (Song) -> Void
    let limit: Int
    let margin: CGFloat

    var body: some View {
        if songs.isEmpty {
            // Loading state
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5) // make it bigger if you want
                    .padding(.top, 20)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }
            }
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(
                    rows: Array(
                        repeating: GridItem(.flexible(), 
                        spacing: 10
                    ), 
                    count: 3), 
                    spacing: 10
                ) {
                    ForEach(songs.prefix(limit), id: \.id) { song in
                        HStack {
                            MusicItemBlock(
                                artwork: song.artwork,
                                title: song.title,
                                artistName: song.artistName,
                                playCount: song.playCount,
                                removeSpacer: false,
                                removeEllipsis: false
                            ) {
                                setSelectedSong(song)
                            }
                            
                            Spacer()
                        }
                        .frame(width: 290)
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct DisplayAlbumsInGrid: View {
    let albums: MusicItemCollection<Album>
    var errorMessage: String?
    let setSelectedAlbum: (Album) -> Void
    let limit: Int
    let margin: CGFloat

    var body: some View {
        if albums.isEmpty {
            // Loading state
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5) // make it bigger if you want
                    .padding(.top, 20)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }
            }
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 8) {
                    ForEach(albums.prefix(limit), id: \.id) { album in
                        VStack {
                            LargeMusicItemBlock(
                                artwork: album.artwork,
                                title: album.title,
                                artistName: album.artistName,
                                playCount: nil,
                                size: 160
                            ) {
                                setSelectedAlbum(album)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct HomeTabButton<Destination: View>: View {
    let title: String
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
        }
            .font(.montserrat(size: 16, weight: .bold))
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .foregroundColor(.resonatePurple)
            .glassEffect()
    }
}

struct HomeView: View {
    let userToken: String
    
    @EnvironmentObject var overlayManager: OverlayManager
    
    @State private var recentlyPlayedSongs: MusicItemCollection<Song> = []
    @State private var recentlyAddedAlbums: MusicItemCollection<Album> = []
    @State private var mostPopularSongs: MusicItemCollection<Song> = []
    @State private var topSongs: MusicItemCollection<Song> = []
    @State private var recentlyPlayedPlaylists: MusicItemCollection<Playlist> = []
    
    @State private var selectedSong: Song?
    @State private var selectedAlbum: Album?
    @State private var selectedPlaylist: Playlist?
    
    let limit = 12
    
    let margin: CGFloat = 20
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView() {
                    TopSpacer()
                    
                    VStack(spacing: 20) {
                        VStack {
                            // Recent Songs
                            SectionHeader(
                                title: "Recent Songs",
                                subtitle: "Back to what you were playing",
                                margin: margin
                            )
                            
                            DisplaySongsInGrid(
                                songs: recentlyPlayedSongs,
                                setSelectedSong: setSelectedSong,
                                limit: limit,
                                margin: margin
                            )
                        }

                        VStack {
                            // Recent Albums
                            SectionHeader(
                                title: "Recent Albums",
                                subtitle: "Albums you have added recently",
                                margin: margin
                            )
                            
                            DisplayAlbumsInGrid(
                                albums: recentlyAddedAlbums,
                                setSelectedAlbum: setSelectedAlbum,
                                limit: limit,
                                margin: margin
                            )
                        }
                        
                        VStack {
                            // Recent Playlists
                            SectionHeader(
                                title: "Recent Playlists",
                                subtitle: "Playlists you’ve explored recently",
                                margin: margin
                            )
                            
                            DisplayPlaylistsInGrid(
                                playlists: recentlyPlayedPlaylists,
                                setSelectedPlaylist: setSelectedPlaylist,
                                limit: limit,
                                margin: margin
                            )
                        }
                        
                        VStack {
                            // Top Songs
                            SectionHeader(
                                title: "Top Songs",
                                subtitle: "Your most played tracks in your library",
                                margin: margin
                            )
                            
                            DisplaySongsInGrid(
                                songs: topSongs,
                                setSelectedSong: setSelectedSong,
                                limit: limit,
                                margin: margin
                            )
                        }
                        
                        VStack {
                            // Top Charts
                            SectionHeader(
                                title: "Apple Music Top Charts",
                                subtitle: "See what songs are popular right now",
                                margin: margin
                            )
                            
                            DisplaySongsInGrid(
                                songs: mostPopularSongs,
                                setSelectedSong: setSelectedSong,
                                limit: limit,
                                margin: margin
                            )
                        }
                        
                        ViewSpacer()
                    }
                }
            }
            .navigationDestination(item: $selectedSong) { song in
                SongView(song: song)
            }
            .navigationDestination(item: $selectedAlbum) { album in
                AlbumView(album: album)
            }
            .navigationDestination(item: $selectedPlaylist) { playlist in
                PlaylistView(playlist: playlist)
            }
            .background(Color.resonateWhite)
        }
        .task {
            async let songs: () = fetchRecentlyPlayedSongs()
            async let albums: () = fetchRecentlyAddedAlbums()
            async let top: () = fetchTopSongs()
            async let playlists: () = fetchRecentlyPlayedPlaylists()
            async let popular: () = fetchPopularSongs()
            
            _ = await [songs, albums, top, playlists, popular]
        }
    }
    
    func fetchPopularSongs() async {
        do {
            var request = MusicCatalogChartsRequest(types: [Song.self])
            request.limit = limit
            let response = try await request.response()

            // Flatten chart songs into a single collection, preserving order by chart and position
            let songs: [Song] = response.songCharts.flatMap { chart in
                chart.items
            }

            await MainActor.run {
                mostPopularSongs = MusicItemCollection(songs.prefix(limit))
            }
        } catch {
            await showError("Failed to fetch songs: \(error.localizedDescription)")
        }
    }
    
    func fetchRecentlyPlayedSongs() async {
        do {
            var request = MusicRecentlyPlayedRequest<Song>()
            request.limit = limit
            let response = try await request.response()
            await MainActor.run {
                recentlyPlayedSongs = response.items
            }
        } catch {
            await showError("Failed to fetch songs: \(error.localizedDescription)")
        }
    }
    
    func fetchRecentlyAddedAlbums() async {
        do {
            let request = MusicLibraryRequest<Album>()
            let response = try await request.response()

            // Sort by libraryAddedDate descending (newest first). Missing dates go to the end.
            let sorted = response.items.sorted { lhs, rhs in
                let l = lhs.libraryAddedDate
                let r = rhs.libraryAddedDate
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
                recentlyAddedAlbums = MusicItemCollection(sorted.prefix(limit))
            }
        } catch {
            await showError(error.localizedDescription)
        }
    }
    
    func fetchRecentlyPlayedPlaylists() async {
        do {
            let request = MusicLibraryRequest<Playlist>()
            let response = try await request.response()

            // Sort by lastPlayedDate descending (newest first). Missing dates go to the end.
            let sorted = response.items.sorted { lhs, rhs in
                let l = lhs.lastPlayedDate
                let r = rhs.lastPlayedDate
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
                recentlyPlayedPlaylists = MusicItemCollection(sorted.prefix(limit))
            }
        } catch {
            await showError(error.localizedDescription)
        }
    }

    func fetchTopSongs() async {
        do {
            let request = MusicLibraryRequest<Song>()
            let response = try await request.response()

            let sorted = response.items
                .filter { $0.playCount != nil }
                .sorted { ($0.playCount ?? 0) > ($1.playCount ?? 0) }

            await MainActor.run {
                topSongs = MusicItemCollection(sorted.prefix(limit))
            }
        } catch {
            overlayManager.showError(error.localizedDescription)
        }
    }
    
    func setSelectedSong(_ song: Song) {
        selectedSong = song
    }
    
    func setSelectedAlbum(_ album: Album) {
        selectedAlbum = album
    }
    
    func setSelectedPlaylist(_ playlist: Playlist) {
        selectedPlaylist = playlist
    }

    func showError(_ message: String) async {
        await displayMessage(message) { msg in
            overlayManager.showError(msg)
        }
    }
}

struct ViewSpacer: View {
    var body: some View {
        Spacer(minLength: 160)
    }
}

struct TopSpacer: View {
    var body: some View {
        Spacer(minLength: 60)
    }
}
