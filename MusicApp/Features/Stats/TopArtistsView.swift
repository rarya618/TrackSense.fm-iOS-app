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
    @State private var isLoading = true
    @State private var loadedArtistStats: [ArtistStat] = []
    
    let artistStats: [ArtistStat]
    let setSelectedArtist: (Artist) -> Void
    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ClassicLoadingView(text: "Loading artists")
                }
            } else {
                ScrollView {
                    DisplayTopArtists(
                        artistStats: Array(artistStats),
                        setSelectedArtist: setSelectedArtist
                    )
                    .padding()
                    
                    ViewSpacer()
                }
                .navigationTitle("Top artists")
            }
        }
        .onAppear {
            loadArtists()
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
