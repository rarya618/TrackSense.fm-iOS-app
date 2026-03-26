//
//  AlbumsTabView.swift
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
    
    @State private var selectedAlbum: Album?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(albums) { album in
                    AlbumRow(album: album) {
                        selectedAlbum = album
                    }
                }
            }
            .padding()
        }
        .navigationDestination(item: $selectedAlbum) { album in
            AlbumView(album: album)
        }
        .task {
            await fetchLibraryAlbums()
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
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
                errorMessage = "Failed to fetch albums: \(error.localizedDescription)"
            }
        }
    }
}
