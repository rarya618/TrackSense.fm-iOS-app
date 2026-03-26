//
//  ArtistRow.swift
//  Resonate
//
//  Created by Russal Arya on 21/9/2025.
//

import SwiftUI
import MusicKit

struct ArtistRow: View {
    let artist: Artist
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ArtistArtworkView(artist: artist, width: 50, height: 50, cornerRadius: 8)
                VStack(alignment: .leading) {
                    Text(artist.name)
                        .font(.headline)
                        .foregroundColor(.customPurple)
                }

                Spacer()
            }
        }
        .buttonStyle(.plain) // removes SwiftUI’s default button tint
    }
}
