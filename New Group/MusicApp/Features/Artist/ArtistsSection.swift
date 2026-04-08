//
//  ArtistsSection.swift
//  Resonate
//
//  Created by Russal Arya on 8/10/2025.
//

import SwiftUI
import MusicKit

struct ArtistsSection: View {
    let key: String
    let artists: [Artist]
    let onSelect: (Artist) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section header
            Text(key)
                .font(.system(size: 18))
                .fontWeight(.bold)
                .padding(.leading, 4)
            
            ForEach(artists) { artist in
                ArtistRow(artist: artist) {
                    onSelect(artist)
                }
            }
        }
    }
}
