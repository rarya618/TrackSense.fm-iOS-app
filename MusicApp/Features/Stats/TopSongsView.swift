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
    
    @State private var isLoading = true
    @State private var loadedSongs: [Song] = []
    
    @State private var selectedSong: Song?
    
    func setSelectedSong(song: Song) {
        selectedSong = song
    }
    
    var body: some View {
        VStack {
            if isLoading {
                VStack {
                    ClassicLoadingView(text: "Loading songs")
                }
            } else {
                ScrollView {
                    DisplayTopSongs(
                        songs: Array(loadedSongs),
                        setSelectedSong: setSelectedSong
                    )
                    .padding()
                    
                    ViewSpacer()
                }
                .navigationTitle("Top songs")
                .navigationDestination(item: $selectedSong) { song in
                    SongView(song: song)
                }
            }
        }
        .onAppear {
            loadSongs()
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
