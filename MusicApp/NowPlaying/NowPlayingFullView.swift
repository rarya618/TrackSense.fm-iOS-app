//
//  NowPlayingFullView.swift
//  Resonate
//
//  Created by Russal Arya on 22/9/2025.
//

import SwiftUI
import MusicKit

struct NowPlayingFullView: View {
    @Binding var isPlayerExpanded: Bool
    
    @State private var currentSong: Song?
    @State private var refreshTask: Task<Void, Never>? = nil
    
    @State private var isPlaying: Bool = false

    @State private var playbackTime: TimeInterval =  SystemMusicPlayer.shared.playbackTime
    
    // Drag state
    @State private var dragOffset: CGFloat = 0
    

//    private var artworkColor: Color {
//        if let cgColor = currentSong?.artwork?.backgroundColor {
//            return Color(cgColor)
//        } else {
//            return Color.resonateLightPurple
//        }
//    }
    
    let gradientStops: [Gradient.Stop] = [
        .init(color: Color(.sRGB, red: 0.659, green: 0.984, blue: 0.827), location: 0),
        .init(color: Color(.sRGB, red: 0.310, green: 0.718, blue: 0.702), location: 0.35),
        .init(color: Color(.sRGB, red: 0.388, green: 0.478, blue: 0.725), location: 0.70),
        .init(color: Color(.sRGB, red: 0.192, green: 0.196, blue: 0.435), location: 1.0)
    ]
//    @State private var rippleOffset: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            // Artwork background color
            LinearGradient(
                gradient: Gradient(stops: gradientStops),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if let song = currentSong {
                TabView {
                    VStack {
                        MediaPlayerView(song: song, isPlaying: isPlaying, playbackTime: playbackTime, togglePlayPause: togglePlayPause)
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 30)
                    
                    
                    VStack {
                        VStack {
                            SongStatsView(song: song)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 28)
                        .background(Color.resonateWhite)
                        .cornerRadius(18)
                    }
                    .padding(.horizontal, 30)
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic)) // keeps the dots
                .frame(maxWidth: .infinity, maxHeight: .infinity) // makes it full width
                .padding(.vertical, 24)
            } else {
                Text("No song is currently playing")
                    .foregroundStyle(Color.landingPurple)
            }
        }
        .onAppear {
            refreshTask?.cancel()
            refreshTask = Task {
                await fetchCurrentlyPlayingWithLibraryData()
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    await fetchCurrentlyPlayingWithLibraryData()
                    
                    // Keep updating in real time
                    playbackTime = SystemMusicPlayer.shared.playbackTime
                }
            }
        }
        .onDisappear {
            refreshTask?.cancel()
            refreshTask = nil
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        // .offset(y: dragOffset)
        // .gesture(
        //     DragGesture()
        //         .onChanged { value in
        //             if value.translation.height > 0 {
        //                 dragOffset = value.translation.height
        //             }
        //         }
        //         .onEnded { value in
        //             if value.translation.height > 150 {
        //                 // dismiss on swipe down
        //                 isPlayerExpanded = false
        //             }
        //             dragOffset = 0
        //         }
        // )
    }
    
    private func togglePlayPause() {
        Task { @MainActor in
            let player = SystemMusicPlayer.shared
            do {
                if isPlaying {
                    // Optimistically update
                    isPlaying = false
                    player.pause()
                } else {
                    // Optimistically update
                    isPlaying = true
                    try await player.play()
                }
            } catch {
                print("Failed to toggle playback: \(error)")
                // Roll back state if something failed
                isPlaying = player.state.playbackStatus == .playing
            }
        }
    }
    
    @MainActor
    func fetchCurrentlyPlayingWithLibraryData() async {
        let player = SystemMusicPlayer.shared
        
        // Keep `isPlaying` in sync every refresh
        isPlaying = player.state.playbackStatus == .playing

        guard let entry = player.queue.currentEntry else {
            if currentSong != nil { currentSong = nil } // only update if changed
            return
        }

        switch entry.item {
        case .song(let song):
            var updatedSong = song

            // Fetch library data for stats, but only overwrite fields that exist
            do {
                var request = MusicLibraryRequest<Song>()
                request.filter(matching: \.id, equalTo: song.id)
                let response = try await request.response()
                if let fullSong = response.items.first {
                    // Only overwrite currentSong if fullSong has extra data
                    updatedSong = fullSong
                }
            } catch {
                // silently ignore
            }

            // Only assign to @State if the ID actually changed
            if currentSong?.id != updatedSong.id {
                currentSong = updatedSong
            }

        default:
            if currentSong != nil { currentSong = nil }
        }
    }
}
