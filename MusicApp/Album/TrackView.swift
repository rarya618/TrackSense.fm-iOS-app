//
//  TrackView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct TrackView: View {
    let track: Track
    
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    ArtworkView(artwork: track.artwork, width: 200, height: 200, cornerRadius: 10)
                    .shadow(radius: 8)
                    .padding(.top, 12)
                    
                    VStack(spacing: 4) {
                        Text(track.title)
                            .fontWeight(.bold)
                            .font(Font.system(size: 20))
                            .foregroundStyle(Color.resonatePurple)
                        
                        Text(track.artistName)
                            .fontWeight(.semibold)
                            .font(Font.system(size: 16))
                            .foregroundStyle(Color.resonateLightPurple)
                        
                        if let albumTitle = track.albumTitle {
                            Text(albumTitle)
                                .foregroundStyle(Color.resonatePurple)
                                .font(Font.system(size: 14))
                        }
                        
                        let genres = track.genreNames
                        
                        Text(genres.map { $0 }.joined(separator: " • "))
                            .font(Font.system(size: 12))
                            .foregroundStyle(Color.resonateLightPurple)
                        
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        Button(action: { playSong(track) }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Play")
                                Spacer()
                                if let duration = track.duration {
                                    Text(formatTime(duration))
                                }
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
                        
                        HStack(spacing:12) {
                            Button(action: {}) {
                                Spacer()
                                Text("View album")
                                Spacer()
                            }
                            .fontWeight(.bold)
                            .font(Font.system(size: 16))
                            .padding(.horizontal, 30)
                            .padding(.vertical, 14)
                            .foregroundStyle(Color.resonatePurple)
                            .background(Color.resonateLightPurple.opacity(0.1))
                            .cornerRadius(12)
                            .frame(maxWidth: .infinity)
                            
                            Button(action: {}) {
                                Spacer()
                                Text("See lyrics")
                                Spacer()
                            }
                            .fontWeight(.bold)
                            .font(Font.system(size: 16))
                            .padding(.horizontal, 30)
                            .padding(.vertical, 14)
                            .foregroundStyle(Color.resonatePurple)
                            .background(Color.resonateLightPurple.opacity(0.1))
                            .cornerRadius(12)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    TrackStatsView(track: track)
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(track.title)
        }
    }
    
    func playSong(_ track: Track) {
        Task {
            do {
                let player = SystemMusicPlayer.shared
                player.queue = [track] // set queue with this track
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
