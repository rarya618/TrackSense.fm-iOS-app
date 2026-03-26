//
//  ArtistArtworkView.swift
//  MusicApp
//
//  Created by Russal Arya on 21/9/2025.
//

import SwiftUI
import MusicKit

struct ArtistArtworkView: View {
    let artist: Artist
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        
        if let artwork = artist.artwork {
            ArtworkImage(artwork, width: width, height: height)
                .cornerRadius(cornerRadius)
        } else {
            Image(systemName: "music.note")
                .frame(width: 50, height: 50)
                .foregroundColor(.customPurple)
                .background(Color.customLightPurple)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
