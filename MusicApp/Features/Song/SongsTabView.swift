//
//  SongsTabView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct SongsTabView: View {
    let userToken: String
    
    @State private var songs: MusicItemCollection<Song> = []
    @State private var errorMessage: String?
    
    @State private var selectedSong: Song?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(songs, id: \.id) { song in
                    SongRow(song: song) {
                        selectedSong = song
                    }
                }
            }
            .padding()
        }
        .navigationDestination(item: $selectedSong) { song in
            SongView(song: song)
        }
        .task {
            await fetchLibrarySongs()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    func fetchLibrarySongs() async {
        do {
            let request = MusicLibraryRequest<Song>()
            let response = try await request.response()
            await MainActor.run {
                songs = response.items
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to fetch songs: \(error.localizedDescription)"
            }
        }
    }
}
