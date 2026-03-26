//
//  AlbumRow.swift
//  MusicApp
//
//  Created by Russal Arya on 21/9/2025.
//

import SwiftUI
import MusicKit

struct AlbumRow: View {
    let album: Album
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                AlbumArtworkView(album: album, width: 50, height: 50, cornerRadius: 8)
                VStack(alignment: .leading) {
                    Text(album.title)
                        .font(.headline)
                        .foregroundColor(.customPurple)
                    Text(album.artistName)
                        .font(.subheadline)
                        .foregroundColor(.customLightPurple)
                }
                
                Spacer()
            }
        }
        .buttonStyle(.plain) // removes SwiftUI’s default button tint
    }
}
