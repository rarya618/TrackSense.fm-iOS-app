//
//  TopAlbumsView.swift
//  Resonate
//
//  Created by Russal Arya on 19/10/2025.
//

import SwiftUI
import MusicKit

struct TopAlbumsView: View {
    @State private var isLoading = true
    @State private var loadedAlbumStats: [AlbumStat] = []
    
    @State private var selectedAlbum: Album?
    
    let albumStats: [AlbumStat]
    
    func setSelectedAlbum(album: Album) {
        selectedAlbum = album
    }

    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ClassicLoadingView(text: "Loading albums")
                }
            } else {
                ScrollView {
                    DisplayTopAlbums(
                        albumStats: Array(albumStats),
                        setSelectedAlbum: setSelectedAlbum
                    )
                    .padding()
                    
                    ViewSpacer()
                }
                .navigationTitle("Top albums")
                .navigationDestination(item: $selectedAlbum) { album in
                    AlbumView(album: album)
                }
            }
        }
        .onAppear {
            loadAlbums()
        }
    }
    
    private func loadAlbums() {
        // Simulate a small async delay to prevent UI freeze
        DispatchQueue.global().async {
            let prepared = albumStats // Do any prep logic here if needed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                loadedAlbumStats = prepared
                isLoading = false
            }
        }
    }
}

struct DisplayTopAlbums: View {
    let albumStats: [AlbumStat]
    let setSelectedAlbum: (Album) -> Void
    var isShowingPlays = true

    var body: some View {
        if albumStats.isEmpty {
            ClassicLoadingView(text: "Loading albums")
        } else {
            LazyVStack(spacing: 8) {
                ForEach(Array(albumStats.enumerated()), id: \.element.id) { (idx, stat) in
                    StatRow(
                        index: idx + 1,
                        title: stat.album.title,
                        subtitle: stat.album.artistName,
                        playCount: stat.totalPlayCount,
                        minutesPlayed: stat.timePlayed,
                        isShowingPlays: isShowingPlays
                    ) {
                        setSelectedAlbum(stat.album)
                    }
                }
            }
        }
    }
}
