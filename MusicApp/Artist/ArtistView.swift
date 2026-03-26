//
//  ArtistView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct ArtistView: View {
    let artist: Artist
    
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    ArtistArtworkView(artist: artist, width: 200, height: 200, cornerRadius: 10)
                    VStack(spacing: 4) {
                        Text(artist.name)
                            .fontWeight(.bold)
                            .font(Font.system(size: 20))
                            .foregroundStyle(Color.resonatePurple)
                    }
                }
            }
        }
        .navigationBarTitle(artist.name)
        .padding()
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
