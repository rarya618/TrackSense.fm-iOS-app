//
//  ArtworkView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct ArtworkView: View {
    let artwork: Artwork?
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        
        if let artwork = artwork {
            ArtworkImage(artwork, width: width, height: height)
                .cornerRadius(cornerRadius)
        } else {
            Image(systemName: "music.note")
                .frame(width: width, height: height)
                .foregroundColor(.resonatePurple)
                .background(Color.resonateLightPurple)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}
