//
//  HomeView.swift
//  MusicApp
//
//  Created by Russal Arya on 20/9/2025.
//

import SwiftUI
import MusicKit

struct HomeSectionTitle: View {
    let value: String
    
    var body: some View {
        HStack() {
            Text(value)
                .fontWeight(.bold)
                .font(Font.system(size: 20))
                .foregroundStyle(Color.resonatePurple)
            
            Spacer()
        }
        .padding(.top, 20)
    }
}

struct DisplayPlaylistsInGrid: View {
    let playlists: MusicItemCollection<Playlist>
    var errorMessage: String?
    let setSelectedPlaylist: (Playlist) -> Void

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
                LazyHGrid(rows: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(playlists.prefix(9), id: \.id) { playlist in
                        VStack {
                            MusicItemBlock(
                                artwork: playlist.artwork,
                                title: playlist.name,
                                artistName: playlist.curatorName,
                                playCount: nil
                            ) {
                                setSelectedPlaylist(playlist)
                            }
                            .padding(.trailing, 6)
                            .frame(maxWidth: 250)
                        }
                    }
                }
            }
        }
    }
}

struct DisplaySongsInGrid: View {
    let songs: MusicItemCollection<Song>
    var errorMessage: String?
    let setSelectedSong: (Song) -> Void

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
                LazyHGrid(rows: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(songs.prefix(9), id: \.id) { song in
                        VStack {
                            SongRow(song: song) {
                                setSelectedSong(song)
                            }
                            .padding(.trailing, 6)
                            .frame(maxWidth: 250)
                        }
                    }
                }
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
            .fontWeight(.bold)
            .font(Font.system(size: 16))
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .foregroundColor(.landingPurple)
            .background(Color.resonateLightTurquoise)
            .cornerRadius(10)
    }
}

struct HomeView: View {
    let userToken: String
    
    @State private var recentlyPlayedSongs: MusicItemCollection<Song> = []
    @State private var topSongs: MusicItemCollection<Song> = []
    @State private var recentlyPlayedPlaylists: MusicItemCollection<Playlist> = []
    @State private var errorMessage: String?
    
    @State private var selectedSong: Song?
    @State private var selectedPlaylist: Playlist?
    
    let limit = 9
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView() {
                    VStack {
                        HStack() {
                            Text("Home")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 14) {
                            HStack(spacing: 14) {
                                HomeTabButton(title: "Songs", destination: SongsTabView(userToken: userToken))
                                
                                HomeTabButton(title: "Albums", destination: AlbumsTabView(userToken: userToken))
                            }
                            
                            HStack(spacing: 14) {
                                HomeTabButton(title: "Artists", destination: ArtistsTabView(userToken: userToken))
                                
                                HomeTabButton(title: "Playlists", destination: PlaylistsTabView(userToken: userToken))
                            }
                        }
                        
                        // Recently Played
                        HomeSectionTitle(value: "Recently Played")
                        DisplaySongsInGrid(
                            songs: recentlyPlayedSongs,
                            setSelectedSong: setSelectedSong
                        )

                        // Top Songs
                        HomeSectionTitle(value: "Top Songs")
                        DisplaySongsInGrid(
                            songs: topSongs,
                            setSelectedSong: setSelectedSong
                        )
                        
                        // Recent Playlists
                        HomeSectionTitle(value: "Recent Playlists")
                        DisplayPlaylistsInGrid(
                            playlists: recentlyPlayedPlaylists,
                            setSelectedPlaylist: setSelectedPlaylist
                        )
                        
                        ViewSpacer()
                    }
                    .padding()
                }
            }
            .navigationDestination(item: $selectedSong) { song in
                SongView(song: song)
            }
            .navigationDestination(item: $selectedPlaylist) { playlist in
                PlaylistView(playlist: playlist)
            }
            .background(Color.resonateWhite)
        }
        .task {
            await fetchRecentlyPlayedSongs()
            await fetchTopSongs()
            await fetchRecentlyPlayedPlaylists()
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
            await MainActor.run {
                errorMessage = "Failed to fetch songs: \(error.localizedDescription)"
            }
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
            
            // Wrap back into MusicItemCollection
            recentlyPlayedPlaylists = MusicItemCollection(sorted.prefix(limit))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchTopSongs() async {
        do {
            let request = MusicLibraryRequest<Song>()
            let response = try await request.response()

            let sorted = response.items
                .filter { $0.playCount != nil }
                .sorted { ($0.playCount ?? 0) > ($1.playCount ?? 0) }

            // Wrap back into MusicItemCollection
            topSongs = MusicItemCollection(sorted.prefix(limit))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func setSelectedSong(song: Song) {
        selectedSong = song
    }
    
    func setSelectedPlaylist(playlist: Playlist) {
        selectedPlaylist = playlist
    }
}

struct ViewSpacer: View {
    var body: some View {
        Spacer(minLength: 120)
    }
}

/// Queues a MusicKit item (Album, Song, Playlist, etc.) to play immediately, without clearing existing items.
/// - Parameters:
///   - item: The MusicKit item to queue.
///   - playImmediately: Whether to start playing the new item right away (default: true).
///   - errorHandler: Optional closure to handle playback errors.
func playItem<Item: PlayableMusicItem>(
    _ item: Item,
    playImmediately: Bool = true,
    errorHandler: ((Error) -> Void)? = nil
) async {
    let player = SystemMusicPlayer.shared

    do {
        // Insert the item after the current entry without clearing the queue
        try await player.queue.insert([item], position: .afterCurrentEntry)
        
        // Switch to next song
        try await player.skipToNextEntry()

        if playImmediately {
            try await player.play()
        }
    } catch {
        errorHandler?(error)
    }
}

