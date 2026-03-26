//
//  SongView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct SongView: View {
    let song: Song
    
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    SongArtworkView(song: song, width: 200, height: 200, cornerRadius: 10)
                    VStack(spacing: 4) {
                        Text(song.title)
                            .fontWeight(.bold)
                            .font(Font.system(size: 20))
                            .foregroundStyle(Color.resonatePurple)
                        
                        Text(song.artistName)
                            .fontWeight(.semibold)
                            .font(Font.system(size: 16))
                            .foregroundStyle(Color.resonateLightPurple)
                        
                        if let albumTitle = song.albumTitle {
                            Text(albumTitle)
                                .foregroundStyle(Color.resonatePurple)
                                .font(Font.system(size: 14))
                        }
                        
                        if let genres = song.genres {
                            ForEach(genres, id: \.self) {
                                genre in Text(genre.name)
                            }
                        }
                    }
                    
                    HStack {
                        Button(action: { playSong(song) }) {
                            HStack {
                                Text("Play")
                                Spacer()
                                if let duration = song.duration {
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
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                        Button("View album") {
                            
                        }
                        .fontWeight(.bold)
                        .font(Font.system(size: 16))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 14)
                        .foregroundStyle(Color.resonatePurple)
                        .background(Color.resonateLightPurple.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                    
                    VStack (spacing: 10) {
                        if let playCount = song.playCount {
                            StatView(title: "Plays", value: playCount.formatted())
                            
                            if let duration = song.duration {
                                let totalMinutes = (Double(playCount) * duration) / 60
                                StatView(title: "Minutes", value: Int(totalMinutes).formatted())
                            }
                        }
                        if let lastPlayed = song.lastPlayedDate {
                            StatView(title: "Last played", value: lastPlayed.formatted())
                        }
                        if let discoveredDate = song.libraryAddedDate {
                            StatView(title: "Discovered", value: discoveredDate.formatted())
                        }
                        if let releaseDate = song.releaseDate {
                            StatView(title: "Release date", value: releaseDate.formatted())
                        }
                    }
                }
            }
        }
        .navigationBarTitle(song.title)
        .padding()
    }
    
    func playSong(_ song: Song) {
        Task {
            do {
                let player = SystemMusicPlayer.shared
                player.queue = [song] // set queue with this song
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

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.bold)
                .foregroundStyle(Color.resonatePurple)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(Color.resonateLightPurple)
        }
        .font(Font.system(size: 16))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}
