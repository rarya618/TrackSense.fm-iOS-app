//
//  AlbumArtworkView.swift
//  MusicApp
//
//  Created by Russal Arya on 21/9/2025.
//

import SwiftUI
import MusicKit

struct AlbumArtworkView: View {
    let album: Album
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        
        if let artwork = album.artwork {
            ArtworkImage(artwork, width: width, height: height)
                .cornerRadius(cornerRadius)
        } else {
            Image(systemName: "music.note")
                .frame(width: width, height: height)
                .foregroundColor(.customPurple)
                .background(Color.customLightPurple)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
