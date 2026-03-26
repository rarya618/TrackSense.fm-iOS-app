//
//  SongDetailsView.swift
//  MusicApp
//
//  Created by Russal Arya on 24/9/2025.
//

import SwiftUI
import MusicKit

struct DetailsView: View {
    let artwork: Artwork?
    let title: String
    let artistName: String
    let albumTitle: String?
    let genreNames: [String]

    var body: some View {
        ArtworkView(artwork: artwork, width: 200, height: 200, cornerRadius: 10)
        .shadow(radius: 8)
        .padding(.top, 12)
        
        VStack(spacing: 4) {
            Text(title)
                .fontWeight(.bold)
                .font(Font.system(size: 20))
                .foregroundStyle(Color.resonatePurple)
            
            Text(artistName)
                .fontWeight(.semibold)
                .font(Font.system(size: 16))
                .foregroundStyle(Color.resonateLightPurple)
            
            if let album = albumTitle {
                Text(album)
                    .foregroundStyle(Color.resonatePurple)
                    .font(Font.system(size: 14))
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
}
