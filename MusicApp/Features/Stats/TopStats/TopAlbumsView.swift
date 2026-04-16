//
//  TopAlbumsView.swift
//  Resonate
//
//  Created by Russal Arya on 19/10/2025.
//

import SwiftUI
import MusicKit

struct TopAlbumsView: View {
    let albumStats: [AlbumStat]
    @State private var isShowingPlays: Bool

    @State private var isLoading = true
    @State private var loadedAlbumStats: [AlbumStat] = []
    @State private var selectedAlbum: Album?

    init(albumStats: [AlbumStat], isShowingPlays: Bool) {
        self.albumStats = albumStats
        self._isShowingPlays = State(initialValue: isShowingPlays)
    }

    func setSelectedAlbum(album: Album) {
        selectedAlbum = album
    }

    var body: some View {
        Group {
            if isLoading {
                ClassicLoadingView(text: "Loading albums")
            } else {
                ScrollView {
                    DisplayTopAlbums(
                        albumStats: Array(loadedAlbumStats),
                        setSelectedAlbum: setSelectedAlbum,
                        isShowingPlays: isShowingPlays
                    )
                    .padding()

                    ViewSpacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(item: $selectedAlbum) { AlbumView(album: $0) }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Top albums")
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
        .onAppear { loadAlbums() }
        .onChange(of: isShowingPlays) {
            loadedAlbumStats = loadedAlbumStats.sorted {
                isShowingPlays ? $0.totalPlayCount > $1.totalPlayCount : $0.timePlayed > $1.timePlayed
            }
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
