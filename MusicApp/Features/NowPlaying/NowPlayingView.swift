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
    
    @State private var isPlaying: Bool = false
    
    @Environment(\.colorScheme) var colorScheme

    let size: CGFloat = 36
    
    private var artworkColor: Color {
        if let cgColor = currentSong?.artwork?.backgroundColor {
            return Color(cgColor)
        } else {
            return Color.landingPurple
        }
    }
    
    private var secondaryColor: Color { artworkColor.adjusted(brightness: -0.1) } // Slightly deeper
    private var highlightColor: Color { artworkColor.adjusted(brightness: 0.1) }  // Slightly lighter
    
    private var primaryColor: Color {
        if let cgColor = currentSong?.artwork?.primaryTextColor {
            return Color(cgColor)
        } else {
            return Color.resonateTurquoise
        }
    }

    private func idealColor(
        textColor: UIColor,
        backgroundColor: UIColor
    ) -> Color {
        let traits = UITraitCollection(userInterfaceStyle: colorScheme == .dark ? .dark : .light)
        let white = UIColor(.resonateWhite).resolvedColor(with: traits)

        let backgroundRatio = backgroundColor.contrastRatio(with: white)
        let textRatio = textColor.contrastRatio(with: white)

        if backgroundRatio >= 3.0 {
            return Color(backgroundColor)
        } else if textRatio >= 3.0 {
            return Color(textColor)
        } else {
            return Color(backgroundColor)
        }
    }

    private var adjustedTextColor: Color {
        if let bgCG = currentSong?.artwork?.backgroundColor,
           let textCG = currentSong?.artwork?.primaryTextColor {
            return idealColor(
                textColor: UIColor(cgColor: textCG),
                backgroundColor: UIColor(cgColor: bgCG)
            )
        }
        return .resonatePurple
    }

    @State private var playbackTime: TimeInterval =  SystemMusicPlayer.shared.playbackTime

    private var safeDuration: TimeInterval {
        if currentSong != nil {
            return max(currentSong?.duration ?? 0, 0)
        }
        
        return 0
    }

    private var clampedPlayback: TimeInterval {
        guard safeDuration > 0 else { return 0 }
        return min(max(playbackTime, 0), safeDuration)
    }
    
    let progressBarHeight: CGFloat = 4
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Main content on top
            HStack(spacing: 12) {
                if let song = currentSong {
                    ArtworkView(
                        artwork: song.artwork,
                        width: size,
                        height: size,
                        cornerRadius: size
                    )

                    HStack {
                        // Song info + controls
                        VStack (alignment: .leading, spacing: 1) {
                            // Scrolling text for long text
                            MarqueeText(
                                text: song.title,
                                font: .montserrat(size: 14, weight: .bold),
                                color: adjustedTextColor,
                                tracking: 14 * -0.025
                            )
                            .frame(height: 17)
                            .clipped()

                            MarqueeText(
                                text: song.artistName,
                                font: .montserrat(size: 13, weight: .medium),
                                color: adjustedTextColor.opacity(0.8),
                                tracking: 13 * -0.025
                            )
                            .frame(height: 16)
                            .clipped()
                            
//                            // Title + artist
//                            Text(song.title)
//                                .font(.montserrat(size: 14, weight: .bold))
//                                .tracking(14 * -0.025)
//                                .lineLimit(1)
//                            
//                            Text(song.artistName)
//                                .font(.montserrat(size: 12, weight: .medium))
//                                .tracking(12 * -0.025)
//                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                    }
                    
                    // Controls
                    HStack (spacing: 8) {
                        Button(action: togglePlayPause) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .id(isPlaying)
                        }
                        .font(.montserrat(size: 22, weight: .semibold))
                        .padding(8)
                        
                        Button(action: {
                            Task { try? await SystemMusicPlayer.shared.skipToNextEntry() }
                        }) {
                            Image(systemName: "forward.end.fill")
                        }
                        .font(.montserrat(size: 20))
                    }
                    .padding(.trailing, 3)
                } else {
                    VStack {
                        Text("No song is currently playing")
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.leading, 10)
            .padding(.trailing, 14)
//            .padding(.top, 8)
//            .padding(.bottom, 6 + progressBarHeight)
//            .padding(.horizontal, 12)
//            .background(
//                LinearGradient(
//                    colors: [
//                        artworkColor.opacity(0.5),
//                        artworkColor.opacity(0.8),
//                        artworkColor.opacity(0.9)
//                    ],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                LinearGradient(
//                    colors: [
//                        artworkColor.opacity(0.45),
//                        artworkColor.opacity(0.75),
//                        artworkColor.opacity(0.9),
//                        artworkColor.opacity(0.85)
//                    ],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                MeshGradient(
//                    width: 2,
//                    height: 2,
//                    points: [
//                        [0, 0], [1, 0],
//                        [0, 1], [1, 1]
//                    ],
//                    colors: [
//                        highlightColor, artworkColor,
//                        secondaryColor, artworkColor.opacity(0.8)
//                    ]
//                )
//            )

            GeometryReader { geo in
                let width = geo.size.width
                let progress = safeDuration > 0 ? clampedPlayback / safeDuration : 0

                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                adjustedTextColor.opacity(0.9),
                                adjustedTextColor.opacity(1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width * progress, height: progressBarHeight)
                    .opacity(progress > 0.02 ? 1 : 0)
                    .animation(.linear(duration: 0.5), value: clampedPlayback)
            }
            .frame(height: progressBarHeight)   // 👈 constrains GeometryReader
        }
        .contentShape(Capsule())
        .clipShape(Capsule())
        .onAppear {
            refreshTask?.cancel()
            refreshTask = Task {
                var lastSongID: MusicItemID? = nil
                while !Task.isCancelled {
                    await fetchCurrentlyPlaying()

                    // Update UI only if song actually changed
                    if currentSong?.id != lastSongID {
                        lastSongID = currentSong?.id
                    }

                    // Smooth playback progress updates
                    playbackTime = SystemMusicPlayer.shared.playbackTime

                    try? await Task.sleep(nanoseconds: 500_000_000) // smoother updates
                }
            }
        }
        .onDisappear {
            refreshTask?.cancel()
            refreshTask = nil
        }
        .foregroundColor(adjustedTextColor)
//        .background(adjustedTextColor.opacity(0.08))
        .background {
            Capsule()
                .fill(adjustedTextColor.opacity(0.06))
                .stroke(adjustedTextColor.opacity(0.25), lineWidth: 1)
        }
//        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 10))
        .glassEffect(.regular)
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 4)
    }
    
    // Initial fetch
    func fetchCurrentlyPlaying() async {
        let player = SystemMusicPlayer.shared

        // Keep `isPlaying` in sync every refresh
        isPlaying = player.state.playbackStatus == .playing

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
}
