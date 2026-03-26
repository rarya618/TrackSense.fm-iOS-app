//
//  AlbumSection.swift
//  Resonate
//
//  Created by Russal Arya on 6/10/2025.
//

import SwiftUI
import MusicKit

struct AlbumSection: View {
    let key: String
    let albums: [Album]
    let onSelect: (Album) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section header
            Text(key)
                .font(.system(size: 18))
                .fontWeight(.bold)
                .padding(.leading, 4)
            
            // Two-column grid
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ],
                spacing: 8
            ) {
                ForEach(albums) { album in
                    AlbumRow(album: album, size: 160) {
                        onSelect(album)
                    }
                }
            }
        }
    }
}
