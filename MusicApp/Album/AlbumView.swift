//
//  AlbumView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct AlbumView: View {
    let album: Album
    
    @State private var errorMessage: String?
//    @State private var selectedTrack: Track?

    @State private var tracks: MusicItemCollection<Track>


    init(album: Album) {
        self.album = album
        _tracks = State(initialValue: album.tracks ?? MusicItemCollection([]))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // Album details
                VStack(spacing: 18) {
                    AlbumArtworkView(album: album, width: 200, height: 200, cornerRadius: 10)
                    VStack(spacing: 4) {
                        Text(album.title)
                            .fontWeight(.bold)
                            .font(Font.system(size: 20))
                            .foregroundStyle(Color.resonatePurple)
                        
                        Text(album.artistName)
                            .fontWeight(.semibold)
                            .font(Font.system(size: 16))
                            .foregroundStyle(Color.resonateLightPurple)
                        
                        Text(album.genreNames.map { $0 }.joined(separator: " • "))
                            .font(Font.system(size: 12))
                            .foregroundStyle(Color.resonateLightPurple)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    
                    HStack {
                        Button(action: { playAlbum(album) }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Play")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .fontWeight(.bold)
                        .font(Font.system(size: 16))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.resonatePurple)
                        .foregroundColor(.buttonLabelColor)
                        .cornerRadius(12)
                        
                        Button(action: {}) {
                            Spacer()
                            Text("Shuffle")
                            Spacer()
                        }
                        .fontWeight(.bold)
                        .font(Font.system(size: 16))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.resonatePurple)
                        .background(Color.resonateLightPurple.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Album tracks
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tracks")
                            .fontWeight(.bold)
                            .font(.system(size: 24))
                        
                        ForEach(tracks) { track in
                            AlbumTrack(track: track)
//                            {
//                                selectedTrack = track
//                            }
                        }
                    }

                    // Album Stats
                    AlbumStatsView(album: album)
                }
                .padding()
            }
            .navigationTitle(album.title)
            .onAppear {
                Task {
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
//            .navigationDestination(item: $selectedTrack) { track in
//                TrackView(track: track)
//            }
        }
    }
    
    func playAlbum(_ album: Album) {
        Task {
            do {
                let player = SystemMusicPlayer.shared
                player.queue = [album] // set queue with this album
                try await player.play() // must be awaited
            } catch {
                await MainActor.run {
                    errorMessage = "Playback failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

