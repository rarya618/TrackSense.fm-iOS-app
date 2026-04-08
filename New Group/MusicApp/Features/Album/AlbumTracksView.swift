//
//  AlbumTracksView.swift
//  Resonate
//
//  Created by Russal Arya on 6/10/2025.
//

import SwiftUI
import MusicKit

struct AlbumTracksView: View {
    var tracks: MusicItemCollection<Track>
    var adjustedArtworkColor: Color
    let setSelectedTrack: (Track) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(tracks) { track in
                TrackRow(
                    track: track,
                    adjustedArtworkColor: adjustedArtworkColor,
                    showArtwork: false,
                    onTap: {setSelectedTrack(track)}
                )
            }
        }
        .cornerRadius(8)
    }
}
