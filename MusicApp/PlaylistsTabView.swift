//
//  SongsTabView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct AlbumsTabView: View {
    let userToken: String
    
    @State private var albums: MusicItemCollection<Album> = []
    @State private var errorMessage: String?
    
    @State private var currentSection = 0
    
    var body: some View {
        ScrollView {
            HStack(spacing: 0) {
                Text("A")
            }
            LazyVStack(spacing: 8) {
                ForEach(albums, id: \.id) { album in
                    AlbumRow(album: album)
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
            let request = MusicLibraryRequest<Album>()
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

struct AlbumRow: View {
    let album: Album
//    let onTap: () -> Void

    var body: some View {
//        Button(action: onTap) {
            HStack(spacing: 12) {
                AlbumArtworkView(album: album)
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
//        }
        .buttonStyle(.plain) // removes SwiftUI’s default button tint
    }
}

struct AlbumArtworkView: View {
    let album: Album

    var body: some View {
        
        if let artwork = album.artwork {
            ArtworkImage(artwork, width: 50, height: 50)
                .cornerRadius(8)
        } else {
            Image(systemName: "music.note")
                .frame(width: 50, height: 50)
                .foregroundColor(.customPurple)
                .background(Color.customLightPurple)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
