//
//  SongsTabView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct ArtistsTabView: View {
    let userToken: String
    
    @State private var artists: MusicItemCollection<Artist> = []
    @State private var errorMessage: String?
    
    @State private var selectedArtist: Artist?
    
    var body: some View {
        ScrollView {
//            HStack(spacing: 0) {
//                Text("A")
//            }
            LazyVStack(spacing: 8) {
                ForEach(artists, id: \.id) { artist in
                    ArtistRow(artist: artist) {
                        selectedArtist = artist
                    }
                }
            }
            .padding()
        }
        .navigationDestination(item: $selectedArtist) { artist in
            ArtistView(artist: artist)
        }
        .task {
            await fetchLibraryArtists()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    func fetchLibraryArtists() async {
        do {
            let request = MusicLibraryRequest<Artist>()
            let response = try await request.response()
            await MainActor.run {
                artists = response.items
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to fetch songs: \(error.localizedDescription)"
            }
        }
    }
}
