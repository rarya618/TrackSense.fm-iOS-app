//
//  MediaPlayerView.swift
//  Resonate
//
//  Created by Russal Arya on 23/9/2025.
//


import SwiftUI
import MusicKit

struct MediaPlayerView: View {
    let song: Song
    var isPlaying: Bool
    var playbackTime: TimeInterval
    let togglePlayPause: () -> Void

    @State private var duration: TimeInterval = 0

    var body: some View {
        VStack(spacing: 24) {
            SongArtworkView(song: song, width: .infinity, height: .infinity, cornerRadius: 10)
                
            // Details
            HStack() {
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                    
                    Text(song.artistName)
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)
                
                Spacer()
            }
            
            // Progress bar
            VStack(spacing: 10) {
                ProgressView(value: CGFloat(playbackTime / (song.duration ?? 0)))
                    .padding(.vertical, 4)
                    .tint(.white)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .cornerRadius(4)
                
                HStack {
                    Text(formatTime(playbackTime))
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                    Spacer()
                    Text("-" + formatTime((song.duration ?? 0) - playbackTime))
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                }
            }
            
            // Playback controls
            HStack {
                Button(action: {}) {
                    Image(systemName: "shuffle")
                }
                .font(.system(size: 24))
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        Task {
                            try? await SystemMusicPlayer.shared.skipToPreviousEntry()
                        }
                    }) {
                        Image(systemName: "backward.fill")
                    }
                    .font(.system(size: 32))
                    
                    Button(action: {
                        togglePlayPause()
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    }
                    .font(.system(size: 56))
                    
                    Button(action: {
                        Task {
                            try? await SystemMusicPlayer.shared.skipToNextEntry()
                        }
                    }) {
                        Image(systemName: "forward.fill")
                    }
                    .font(.system(size: 32))
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "repeat")
                }
                .font(.system(size: 24))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
                            
            // Secondary controls
            HStack {
                Button(action: {}) {
                    Image(systemName: "quote.bubble")
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "airplayaudio")
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "music.note.list")
                }
            }
            .font(.system(size: 24))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 28)
            .padding(.vertical, 18)
            .background(.white)
            .foregroundStyle(Color.landingPurple)
            .cornerRadius(.infinity)
        }
        .foregroundStyle(.white)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
