//
//  AlbumTracksView.swift
//  Resonate
//
//  Created by Russal Arya on 6/10/2025.
//

import SwiftUI
import MusicKit

struct PlaylistTracksView: View {
    var tracks: MusicItemCollection<Track>
    var adjustedArtworkColor: Color
    let setSelectedTrack: (Track) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(tracks) { track in
                TrackRow(
                    track: track,
                    adjustedArtworkColor: adjustedArtworkColor,
                    showArtwork: true,
                    onTap: {setSelectedTrack(track)}
                )
            }
        }
        .cornerRadius(8)
    }
}
