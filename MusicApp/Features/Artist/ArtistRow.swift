//
//  ArtistRow.swift
//  Resonate
//
//  Created by Russal Arya on 21/9/2025.
//

import SwiftUI
import MusicKit

struct ArtistRow: View {
    let artist: Artist
    let onTap: () -> Void

//    @State private var libraryAlbums: [Album] = []
//    @State private var tracks: MusicItemCollection<Track> = []

    @State private var errorMessage: String?

//    var playCount: Int { getTotalPlayCount(tracks) }
//    var timePlayed: Double { getTotalTimePlayed(tracks) }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ArtistArtworkView(artist: artist, width: 50, height: 50, cornerRadius: 8)
                VStack(alignment: .leading) {
                    Text(artist.name)
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.customPurple)
                        .lineLimit(1)
                    
//                    Text(libraryAlbums.count.formatted() + " albums – " + tracks.count.formatted() + " tracks")
//                        .font(.system(size: 14))
//                        .foregroundColor(.customLightPurple)
//                        .lineLimit(1)
                    
//                    Text(playCount.formatted() + " plays – " + timePlayed.formatted() + " minutes")
//                        .font(.system(size: 14))
//                        .foregroundColor(.customLightPurple)
//                        .lineLimit(1)
                }

                Spacer()
            }
        }
//        .task {
//            do {
//                let albums = try await getAlbumsFromLibrary(for: artist)
//
//                await MainActor.run {
//                    libraryAlbums = albums
//                    errorMessage = albums.isEmpty ? "Albums not found in library" : nil
//                }
//
//                // Fetch all tracks from the albums
//                if !albums.isEmpty {
//                    let fetchedTracks = try await fetchTracksFromAlbums(albums)
//                    await MainActor.run {
//                        tracks = MusicItemCollection(fetchedTracks)
//                    }
//                }
//            } catch {
//                await MainActor.run {
//                    errorMessage = "Fetch artist failed: \(error.localizedDescription)"
//                }
//            }
//        }
        .buttonStyle(.plain) // removes SwiftUI’s default button tint
    }
}
