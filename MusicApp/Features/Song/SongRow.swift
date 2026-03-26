//
//  SongRow.swift
//  MusicApp
//
//  Created by Russal Arya on 21/9/2025.
//

import SwiftUI
import MusicKit

struct SongRow: View {
    let song: Song
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                SongArtworkView(song: song, width: 50, height: 50, cornerRadius: 10)
                VStack(alignment: .leading) {
                    Text(song.title)
                        .font(.headline)
                        .foregroundColor(.resonatePurple)
                    Text(song.artistName)
                        .font(.subheadline)
                        .foregroundColor(.resonateLightPurple)
                }

                Spacer()
            }
        }
        .buttonStyle(.plain) // removes SwiftUI’s default button tint
    }
}
