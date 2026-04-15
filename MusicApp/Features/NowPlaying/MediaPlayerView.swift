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
    var isPlayerMinimised: Bool
    var isSongInLibrary: Bool
    var playbackTime: TimeInterval
    let togglePlayPause: () -> Void
    var artworkColor: Color
    var primaryColor: Color
    let toggleMenu: () -> Void
    
    @State private var isDraggingProgress = false
    @State private var dragProgress: TimeInterval = 0

    @State private var haptic = UIImpactFeedbackGenerator(style: .soft)
    @State private var isSwipingTrack = false
    private let swipeThreshold: CGFloat = 60
    @State private var swipeOffsetX: CGFloat = 0
    
    let player = SystemMusicPlayer.shared
    
    private var safeDuration: TimeInterval {
        max(song.duration ?? 0, 0)
    }

    private var clampedPlayback: TimeInterval {
        guard safeDuration > 0 else { return 0 }
        return min(max(playbackTime, 0), safeDuration)
    }

    private var remaining: TimeInterval {
        max(safeDuration - clampedPlayback, 0)
    }
    
    private func currentProgressFraction() -> CGFloat {
        let activeTime = isDraggingProgress ? dragProgress : clampedPlayback
        return safeDuration > 0 ? CGFloat(activeTime / safeDuration) : 0
    }

    let progressBarSize: CGFloat = 10
    
    var body: some View {
//        let size: CGFloat = isPlayerMinimised ? 72 : 338
        
        VStack(spacing: 24) {
            // Details
            HStack(spacing: 16) {
//                VStack {
//                    ArtworkView (
//                        artwork: song.artwork,
//                        width:  size,
//                        height: size,
//                        cornerRadius: isPlaying ? 10 : 20
//                    )
//                    .shadow(
//                        color: Color.black.opacity(0.25),
//                        radius: 25,
//                        x: 0,
//                        y: 8
//                    )
//                    .offset(x: swipeOffsetX)
//                    .rotationEffect(.degrees(Double(swipeOffsetX / 25)))
//                    .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.9), value: swipeOffsetX)
//                    .scaleEffect(isPlayerMinimised ? 1.0 : 1.03)
//                    .animation(.spring(response: 0.45, dampingFraction: 0.85), value: isPlayerMinimised)
//                    .transition(.scale.combined(with: .opacity))
//                    .fixedSize(horizontal: false, vertical: false)
//                }
//                .simultaneousGesture(
//                    DragGesture(minimumDistance: 20, coordinateSpace: .local)
//                        .onChanged { value in
//                            // Avoid conflicts with progress scrubbing
//                            if isDraggingProgress { return }
//                            // Only treat predominantly horizontal drags as track swipes
//                            if abs(value.translation.width) > abs(value.translation.height) {
//                                isSwipingTrack = true
//                            }
//                            if isSwipingTrack {
//                                swipeOffsetX = value.translation.width
//                            }
//                        }
//                        .onEnded { value in
//                            defer { isSwipingTrack = false }
//
//                            if isDraggingProgress {
//                                swipeOffsetX = 0
//                                return
//                            }
//
//                            // Only act on predominantly horizontal swipes
//                            guard abs(value.translation.width) > abs(value.translation.height) else {
//                                swipeOffsetX = 0
//                                return
//                            }
//
//                            let direction: CGFloat = value.translation.width < 0 ? -1 : 1
//
//                            if value.translation.width <= -swipeThreshold {
//                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                withAnimation(.easeInOut(duration: 0.18)) {
//                                    swipeOffsetX = direction * 420 // animate off to the left
//                                }
//                                Task {
//                                    try? await player.skipToNextEntry()
//                                    await MainActor.run {
//                                        withAnimation(.interactiveSpring(response: 0.28, dampingFraction: 0.9)) {
//                                            swipeOffsetX = 0
//                                        }
//                                    }
//                                }
//                            } else if value.translation.width >= swipeThreshold {
//                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                withAnimation(.easeInOut(duration: 0.18)) {
//                                    swipeOffsetX = direction * 420 // animate off to the right
//                                }
//                                Task {
//                                    if clampedPlayback < 10 {
//                                        try? await player.skipToPreviousEntry()
//                                    } else {
//                                        player.restartCurrentEntry()
//                                    }
//                                    await MainActor.run {
//                                        withAnimation(.interactiveSpring(response: 0.28, dampingFraction: 0.9)) {
//                                            swipeOffsetX = 0
//                                        }
//                                    }
//                                }
//                            } else {
//                                // Not far enough: snap back
//                                withAnimation(.interactiveSpring(response: 0.28, dampingFraction: 0.9)) {
//                                    swipeOffsetX = 0
//                                }
//                            }
//                        }
//                )
//                .frame(width: size, height: size)
                
                if isPlayerMinimised {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(song.title)
                            .font(.montserrat(size: 20, weight: .bold))
                            .lineLimit(1)
                        
                        Text(song.artistName)
                            .font(.montserrat(size: 16))
                            .lineLimit(1)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    Spacer()
                }
            }
            .padding(.horizontal, isPlayerMinimised ? 10 : 0)
            .padding(.bottom, isPlayerMinimised ? 10 : 0)
            
            if !isPlayerMinimised {
                VStack(spacing: 22) {
                    // Details
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                if let audioVariants = song.audioVariants {
                                    if let lastVariant = audioVariants.last {
                                        Pill(
                                            text: convertAudioVariantToText(audioVariant: lastVariant),
                                            foregroundColor: artworkColor,
                                            backgroundColor: primaryColor
                                        )
                                    }
                                }

                                if !isSongInLibrary {
                                    Pill(
                                        text: "Not in library",
                                        foregroundColor: artworkColor,
                                        backgroundColor: primaryColor
                                    )
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                MarqueeText(
                                    text: song.title,
                                    font: .montserrat(size: 20, weight: .bold),
                                    color: primaryColor,
                                    tracking: 20 * -0.025
                                )
                                .frame(height: 28)
                                .clipped()

                                MarqueeText(
                                    text: song.artistName,
                                    font: .montserrat(size: 16, weight: .medium),
                                    color: primaryColor.opacity(0.8),
                                    tracking: 16 * -0.025
                                )
                                .frame(height: 22)
                                .clipped()
                            }
                        }
                        .padding(.bottom, 2)
                        
                        Spacer()
//                        
//                        Button(action: toggleMenu) {
//                            Image(systemName: "ellipsis")
//                                .fontWeight(.bold)
//                                .font(Font.montserrat(size: 20, weight: .bold))
//                                .foregroundColor(primaryColor)
//                                .frame(width: 32, height: 32)
//                                .background(primaryColor.opacity(0.12))
//                                .clipShape(Circle())
//                                .glassEffect(.clear)
//                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.horizontal, 8)
                    
                    // Progress bar
                    HStack(spacing: 12) {
                        Text(formatTime(clampedPlayback))
                            .font(.montserrat(size: 14))
                            .fontWeight(.bold)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                Capsule()
                                    .fill(primaryColor.opacity(0.25))

                                // Filled portion (based on playback)
                                Capsule()
                                    .fill(LinearGradient(colors: [primaryColor, primaryColor.opacity(0.6)],
                                                         startPoint: .leading, endPoint: .trailing))
                                    .frame(width: CGFloat(currentProgressFraction()) * geometry.size.width)
                                    .shadow(
                                        color: primaryColor.opacity(isDraggingProgress ? 0.6 : 0),
                                        radius: isDraggingProgress ? 6 : 0
                                    )
                                    .animation(.easeOut(duration: 0.2), value: isDraggingProgress)

                                // Draggable handle
                                Circle()
                                    .fill(primaryColor)
                                    .frame(width: progressBarSize, height: progressBarSize)
                                    .offset(
                                        x: min(
                                            max(CGFloat(currentProgressFraction()) * geometry.size.width - CGFloat(8), 0),
                                            geometry.size.width - progressBarSize
                                        )
                                    )
                                    .shadow(color: primaryColor.opacity(0.4), radius: 3, y: 1)
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                let fraction = min(max(value.location.x / geometry.size.width, 0), 1)
                                                dragProgress = fraction * safeDuration
                                                isDraggingProgress = true
                                            }
                                            .onEnded { value in
                                                let fraction = min(max(value.location.x / geometry.size.width, 0), 1)
                                                let newTime = fraction * safeDuration
                                                withAnimation(.easeOut(duration: 0.25)) {
                                                    isDraggingProgress = false
                                                }
                                                Task {
                                                    try? await Task.sleep(nanoseconds: 100_000_000) // brief delay for smoothness
                                                    await MainActor.run {
                                                        withAnimation(.easeInOut(duration: 0.2)) {
                                                            player.playbackTime = newTime
                                                        }
                                                    }
                                                }
                                            }
                                    )
                            }
                        }
                        .frame(height: progressBarSize)
                        .padding(.vertical, 3)
                        .animation(.easeInOut(duration: 0.25), value: isDraggingProgress)

                        Text("-" + formatTime(remaining))
                            .font(.montserrat(size: 14))
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
//                    .glassEffect(.clear)
//                    .padding(.horizontal, 6)
                
                    // Playback controls
                    HStack(spacing: 28) {
                        // Shuffle button
                        Button(action: {
                            Task {
                                if player.state.shuffleMode == .songs {
                                    player.state.shuffleMode = .off
                                } else {
                                    player.state.shuffleMode = .songs
                                }
                            }
                        }) {
                            let isActive = player.state.shuffleMode == .songs
                            
                            Image(systemName: "shuffle")
                                .font(.montserrat(size: 20, weight: isActive ? .bold : .regular))
                                .foregroundStyle(
                                    isActive
                                    ? primaryColor.opacity(0.95)
                                    : primaryColor.opacity(0.6)
                                )
                                .frame(width: 48, height: 40)
                                .background(
                                    Capsule()
                                        .fill(
                                            isActive
                                            ? primaryColor.opacity(0.22)
                                            : Color.clear
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            isActive
                                            ? primaryColor.opacity(0.45)
                                            : .clear,
                                            lineWidth: 1
                                        )
                                )
                                .animation(.easeInOut(duration: 0.2), value: player.state.shuffleMode)
                        }
                        
                        // Playback controls
                        HStack(spacing: 32) {
                            Button(action: {
                                Task {
                                    if clampedPlayback < 10 {
                                        try? await player.skipToPreviousEntry()
                                    } else {
                                        player.restartCurrentEntry()
                                    }
                                }
                            }) {
                                Image(systemName: "backward.end.fill")
                            }
                            .font(.montserrat(size: 32))
//                            .frame(width: 48, height: 48)
//                            .glassEffect(.clear)
                            
                            Button(action: {
                                haptic.impactOccurred()
                                togglePlayPause()
                            }) {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .scaleEffect(isPlaying ? 1 : 0.8)
                                    .id(isPlaying) // force view swap
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPlaying)
                            }
                            .font(.montserrat(size: 48))
//                            .frame(width: 64, height: 64)
//                            .glassEffect(.clear)
                            
                            Button(action: {
                                Task {
                                    try? await player.skipToNextEntry()
                                }
                            }) {
                                Image(systemName: "forward.end.fill")
                            }
                            .font(.montserrat(size: 32))
//                            .frame(width: 48, height: 48)
//                            .glassEffect(.clear)
                        }
                        
                        // Repeat button
                        Button(action: {
                            Task {
                                if player.state.repeatMode == MusicPlayer.RepeatMode.none {
                                    player.state.repeatMode = .all
                                } else if player.state.repeatMode == MusicPlayer.RepeatMode.all  {
                                    player.state.repeatMode = .one
                                } else {
                                    player.state.repeatMode = MusicPlayer.RepeatMode.none
                                }
                            }
                        }) {
                            let isNotRepeating = player.state.repeatMode == MusicPlayer.RepeatMode.none
                            
                            Image(systemName: player.state.repeatMode == .one ? "repeat.1" : "repeat")
                                .font(.montserrat(size: 20, weight: isNotRepeating ? .regular : .bold))
                                .foregroundStyle(
                                    isNotRepeating
                                    ? primaryColor.opacity(0.6)
                                    : primaryColor.opacity(0.95)
                                )
                                .frame(width: 48, height: 40)
                                .background(
                                    Capsule()
                                        .fill(
                                            isNotRepeating
                                            ? Color.clear
                                            : primaryColor.opacity(0.22)
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            isNotRepeating
                                            ? .clear
                                            : primaryColor.opacity(0.45),
                                            lineWidth: 1
                                        )
                                )
//                                .foregroundStyle(isNotRepeating ? primaryColor : artworkColor)
//                                .frame(width: 48, height: 40)
//                                .background(
//                                    Capsule()
//                                        .fill(primaryColor.opacity(isNotRepeating ? 0 : 0.8))
//                                )
                                .animation(.easeInOut(duration: 0.2), value: player.state.repeatMode)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
        }
        .foregroundStyle(primaryColor)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPlayerMinimised)
        .animation(.easeInOut(duration: 0.25), value: isPlaying)
        .onAppear {
            haptic.prepare()
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
