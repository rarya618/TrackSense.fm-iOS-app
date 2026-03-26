//
//  NowPlayingView.swift
//  Resonate
//
//  Created by Russal Arya on 21/9/2025.
//

import SwiftUI
import MusicKit

struct NowPlayingView: View {
    let isPlayerExpanded: Bool
    
    @State private var currentSong: Song?
    @State private var refreshTask: Task<Void, Never>? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            if let song = currentSong {
                SongArtworkView(song: song, width: 44, height: 44, cornerRadius: 4)
                VStack(alignment: .leading, spacing: 0) {
                    Text(song.title)
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                    
                    Text(song.artistName)
                        .font(.system(size: 14))
                }
                Spacer()
                Image(systemName: "pause.fill")
                    .font(.system(size: 24))
                
                Image(systemName: "forward.fill")
                    .font(.system(size: 24))
            } else {
                Text("No song is currently playing")
            }
        }
        .onAppear {
            refreshTask?.cancel()
            refreshTask = Task {
                await fetchCurrentlyPlaying()
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    await fetchCurrentlyPlaying()
                }
            }
        }
        .onDisappear {
            refreshTask?.cancel()
            refreshTask = nil
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.landingPurple)
        .foregroundColor(.resonateLightTurquoise)
        .cornerRadius(10)
    }
    
    /// Initial fetch
    func fetchCurrentlyPlaying() async {
        let player = SystemMusicPlayer.shared
        if let entry = player.queue.currentEntry {
            switch entry.item {
            case .song(let song):
                await MainActor.run {
                    self.currentSong = song
                }
            default:
                // Not a song (e.g., radio, music video, etc.)
                await MainActor.run {
                    self.currentSong = nil
                }
            }
        } else {
            await MainActor.run {
                self.currentSong = nil
            }
        }
    }
}

