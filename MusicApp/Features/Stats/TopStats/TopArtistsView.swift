//
//  TopArtistsView.swift
//  TrackSense
//
//  Created by Russal Arya on 19/10/2025.
//

import SwiftUI
import MusicKit

struct DisplayTopArtists: View {
    let artistStats: [ArtistStat]
    var errorMessage: String?
    let setSelectedArtist: (Artist) -> Void
    var isShowingPlays = true

    var body: some View {
        if artistStats.isEmpty {
            ClassicLoadingView(text: "Loading artists")
        } else {
            LazyVStack(spacing: 8) {
                ForEach(Array(artistStats.enumerated()), id: \.element.id) { (idx, stat) in
                    StatRow(
                        index: idx + 1,
                        title: stat.artist.name,
                        subtitle: nil,
                        playCount: stat.totalPlayCount,
                        minutesPlayed: stat.timePlayed,
                        isShowingPlays: isShowingPlays
                    ) {
                        setSelectedArtist(stat.artist)
                    }
                }
            }
        }
    }
}

struct TopArtistsView: View {
    let artistStats: [ArtistStat]
    let setSelectedArtist: (Artist) -> Void
    @State private var isShowingPlays: Bool

    @State private var isLoading = true
    @State private var loadedArtistStats: [ArtistStat] = []

    init(artistStats: [ArtistStat], setSelectedArtist: @escaping (Artist) -> Void, isShowingPlays: Bool) {
        self.artistStats = artistStats
        self.setSelectedArtist = setSelectedArtist
        self._isShowingPlays = State(initialValue: isShowingPlays)
    }

    var body: some View {
        Group {
            if isLoading {
                ClassicLoadingView(text: "Loading artists")
            } else {
                ScrollView {
                    DisplayTopArtists(
                        artistStats: Array(loadedArtistStats),
                        setSelectedArtist: setSelectedArtist,
                        isShowingPlays: isShowingPlays
                    )
                    .padding()

                    ViewSpacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Top artists")
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
        .onAppear { loadArtists() }
        .onChange(of: isShowingPlays) {
            loadedArtistStats = loadedArtistStats.sorted {
                isShowingPlays ? $0.totalPlayCount > $1.totalPlayCount : $0.timePlayed > $1.timePlayed
            }
        }
    }
    
    private func loadArtists() {
        // Simulate a small async delay to prevent UI freeze
        DispatchQueue.global().async {
            let prepared = artistStats // Do any prep logic here if needed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                loadedArtistStats = prepared
                isLoading = false
            }
        }
    }
}
