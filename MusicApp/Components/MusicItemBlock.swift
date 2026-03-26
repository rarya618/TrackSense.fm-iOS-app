//
//  AlbumRow.swift
//  MusicApp
//
//  Created by Russal Arya on 24/9/2025.
//


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

    var body: some View {
        NavigationLink(destination: AlbumView(album: album)) {
            HStack(spacing: 12) {
                ArtworkView(artwork: album.artwork, width: 50, height: 50, cornerRadius: 8)
                VStack(alignment: .leading) {
                    Text(album.title)
                        .font(.headline)
                        .foregroundColor(.customPurple)
                        .lineLimit(1)
                    
                    Text(album.artistName)
                        .font(.subheadline)
                        .foregroundColor(.customLightPurple)
                        .lineLimit(1)
                }
                
                Spacer()
            }
        }
    }
}
