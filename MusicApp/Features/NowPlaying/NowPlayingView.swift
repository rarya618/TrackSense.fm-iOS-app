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

    @EnvironmentObject var sessionManager: SessionManager

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
            .frame(height: progressBarHeight)
        }
        .contentShape(Capsule())
        .clipShape(Capsule())
        .overlay(alignment: .topTrailing) {
            if sessionManager.isSessionActive {
                Circle()
                    .fill(.red)
                    .frame(width: 9, height: 9)
                    .padding(.top, 6)
                    .padding(.trailing, 10)
            }
        }
        .onAppear {
            if !isPlayerExpanded { startRefreshTask() }
        }
        .onDisappear {
            refreshTask?.cancel()
            refreshTask = nil
        }
        .onChange(of: isPlayerExpanded) { _, expanded in
            if expanded {
                refreshTask?.cancel()
                refreshTask = nil
            } else {
                startRefreshTask()
            }
        }
        .foregroundColor(adjustedTextColor)
        .background {
            Capsule()
                .fill(adjustedTextColor.opacity(0.06))
                .stroke(adjustedTextColor.opacity(0.25), lineWidth: 1)
        }
        .glassEffect(.regular.interactive())
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 4)
    }

    func startRefreshTask() {
        refreshTask?.cancel()
        refreshTask = Task {
            var lastSongID: MusicItemID? = nil
            while !Task.isCancelled {
                await fetchCurrentlyPlaying()

                if currentSong?.id != lastSongID {
                    lastSongID = currentSong?.id
                    playbackTime = 0
                }

                playbackTime = SystemMusicPlayer.shared.playbackTime

                do {
                    try await Task.sleep(nanoseconds: 500_000_000)
                } catch {
                    break
                }
            }
        }
    }

    func fetchCurrentlyPlaying() async {
        let player = SystemMusicPlayer.shared

        isPlaying = player.state.playbackStatus == .playing

        if let entry = player.queue.currentEntry {
            switch entry.item {
            case .song(let song):
                await MainActor.run {
                    self.currentSong = song
                }
            default:
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
                    isPlaying = false
                    player.pause()
                } else {
                    isPlaying = true
                    try await player.play()
                }
            } catch {
                print("Failed to toggle playback: \(error)")
                isPlaying = player.state.playbackStatus == .playing
            }
        }
    }
}
