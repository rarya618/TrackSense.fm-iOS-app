//
//  AlbumRow.swift
//  Resonate
//
//  Created by Russal Arya on 21/9/2025.
//

import SwiftUI
import MusicKit

struct AlbumRow: View {
    let album: Album
    let size: CGFloat
    let onTap: () -> Void
    
    @State private var errorMessage: String?
    @State private var tracks: MusicItemCollection<Track>
    
    init(album: Album, size: CGFloat, onTap: @escaping () -> Void) {
        self.album = album
        self.size = size
        self.onTap = onTap
        _errorMessage = State(initialValue: nil)
        _tracks = State(initialValue: album.tracks ?? MusicItemCollection([]))
    }

    var playCount: Int { getTotalPlayCount(tracks) }
    var timePlayed: Double { getTotalTimePlayed(tracks) }

    var body: some View {
        LargeMusicItemBlock(
            artwork: album.artwork,
            title: album.title,
            artistName: album.artistName,
            playCount: playCount,
            size: size
        ) {
            onTap()
        }
        .task {
            if album.tracks == nil {
                do {
                    let fullAlbum = try await album.with([.tracks])
                    tracks = fullAlbum.tracks ?? MusicItemCollection([])

                } catch {
                    errorMessage = "Failed to load tracks"
                }
            }
        }
    }
}

