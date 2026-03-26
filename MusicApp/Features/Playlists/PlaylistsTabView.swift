//
//  SongsTabView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct PlaylistsTabView: View {
    let userToken: String
    
    @State private var albums: MusicItemCollection<Playlist> = []
    @State private var errorMessage: String?
    
    @State private var currentSection = 0
    
    var body: some View {
        ScrollView {
//            HStack(spacing: 0) {
//                Text("A")
//            }
            LazyVStack(spacing: 8) {
                ForEach(albums, id: \.id) { playlist in
                    PlaylistRow(playlist: playlist)
                }
            }
            .padding()
        }
        .task {
            await fetchLibraryAlbums()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    func fetchLibraryAlbums() async {
        do {
            let request = MusicLibraryRequest<Playlist>()
            let response = try await request.response()
            await MainActor.run {
                albums = response.items
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to fetch songs: \(error.localizedDescription)"
            }
        }
    }
}

struct PlaylistRow: View {
    let playlist: Playlist
//    let onTap: () -> Void

    var body: some View {
//        Button(action: onTap) {
            HStack(spacing: 12) {
                PlaylistArtworkView(playlist: playlist)
                VStack(alignment: .leading) {
                    Text(playlist.name)
                        .font(.headline)
                        .foregroundColor(.resonatePurple)
//                    Text(playlist.curatorName)
//                        .font(.subheadline)
//                        .foregroundColor(.resonateLightPurple)
                }

                Spacer()
            }
//        }
        .buttonStyle(.plain) // removes SwiftUI’s default button tint
    }
}

struct PlaylistArtworkView: View {
    let playlist: Playlist

    var body: some View {
        
        if let artwork = playlist.artwork {
            ArtworkImage(artwork, width: 50, height: 50)
                .cornerRadius(8)
        } else {
            Image(systemName: "music.note")
                .frame(width: 50, height: 50)
                .foregroundColor(.resonatePurple)
                .background(Color.resonateLightPurple)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
