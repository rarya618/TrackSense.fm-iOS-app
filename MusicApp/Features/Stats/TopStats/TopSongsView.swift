//
//  TopSongsView.swift
//  Resonate
//
//  Created by Russal Arya on 19/10/2025.
//

import SwiftUI
import MusicKit

struct TopSongsView: View {
    let songs: [Song]
    @State private var isShowingPlays: Bool

    @State private var isLoading = true
    @State private var loadedSongs: [Song] = []
    @State private var selectedSong: Song?

    init(songs: [Song], isShowingPlays: Bool) {
        self.songs = songs
        self._isShowingPlays = State(initialValue: isShowingPlays)
    }

    func setSelectedSong(song: Song) {
        selectedSong = song
    }

    var body: some View {
        VStack {
            if isLoading {
                ClassicLoadingView(text: "Loading songs")
            } else {
                ScrollView {
                    DisplayTopSongs(
                        songs: Array(loadedSongs),
                        setSelectedSong: setSelectedSong,
                        isShowingPlays: isShowingPlays
                    )
                    .padding()

                    ViewSpacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(item: $selectedSong) { SongView(song: $0) }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Top songs")
                            .font(.montserrat(size: 17, weight: .bold))
                            .tracking(17 * -0.025)
                            
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            generateMenu(getSortingMenu(
                                isShowingPlays: isShowingPlays,
                                setShowingPlays: { isShowingPlays = $0 }
                            ))
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.resonatePurple)
                        }
                    }
                }
            }
        }
        .onAppear { loadSongs() }
        .onChange(of: isShowingPlays) {
            loadedSongs = loadedSongs.sorted {
                if isShowingPlays {
                    return ($0.playCount ?? 0) > ($1.playCount ?? 0)
                } else {
                    let l = ($0.playCount ?? 0) * Int($0.duration ?? 0)
                    let r = ($1.playCount ?? 0) * Int($1.duration ?? 0)
                    return l > r
                }
            }
        }
    }
    
    private func loadSongs() {
        // Simulate a small async delay to prevent UI freeze
        DispatchQueue.global().async {
            let prepared = songs // Do any prep logic here if needed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                loadedSongs = prepared
                isLoading = false
            }
        }
    }
}

struct DisplayTopSongs: View {
    let songs: [Song]
    var errorMessage: String?
    let setSelectedSong: (Song) -> Void
    var isShowingPlays = true

    var body: some View {
        if songs.isEmpty {
            // Loading state
            VStack {
                ClassicLoadingView(text: "Loading songs")

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }
            }
        } else {
            LazyVStack(spacing: 8) {
                ForEach(Array(songs.enumerated()), id: \.element.id) { (idx, song) in
                    if let playCount = song.playCount {
                        if let duration = song.duration {
                            let totalMinutes = Int(getMinutesPlayed(playCount: playCount, duration: duration))
                            
                            StatRow(
                                index: idx + 1,
                                title: song.title,
                                subtitle: song.artistName,
                                playCount: song.playCount ?? 0,
                                minutesPlayed: totalMinutes,
                                isShowingPlays: isShowingPlays
                            ) {
                                setSelectedSong(song)
                            }
                        }
                    }
                }
            }
        }
    }
}
