//
//  SessionsView.swift
//  TrackSense
//
//  Created by Russal Arya on 15/4/2026.
//

import SwiftUI
import MusicKit

struct SessionsView: View {
    var color: Color = .primary
    var bgColor: Color = Color(.systemBackground)

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "waveform.circle")
                .font(.system(size: 64))
                .foregroundStyle(color.opacity(0.25))

            VStack(spacing: 8) {
                Text("Coming Soon")
                    .font(.montserrat(size: 20, weight: .bold))

                Text("Sessions are on their way.")
                    .font(.montserrat(size: 15))
                    .foregroundStyle(color.opacity(0.5))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(color)
        .background(bgColor)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sessions")
                    .font(.montserrat(size: 17, weight: .bold))
                    .tracking(17 * -0.025)
            }
        }
    }
}

/*
struct SessionsView_Full: View {
    @EnvironmentObject var sessionManager: SessionManager

    var color: Color = .primary
    var bgColor: Color = Color(.systemBackground)

    @State private var currentSong: Song?
    @State private var refreshTask: Task<Void, Never>? = nil

    private var sessionTimeString: String {
        guard let start = sessionManager.sessionStartTime else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return "Started \(formatter.string(from: start))"
    }

    var body: some View {
        Group {
            if sessionManager.isSessionActive {
                activeSessionView
            } else {
                emptyStateView
            }
        }
        .foregroundStyle(color)
        .background(bgColor)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sessions")
                    .font(.montserrat(size: 17, weight: .bold))
                    .tracking(17 * -0.025)
            }
            if sessionManager.isSessionActive {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("End") {
                        sessionManager.endSession()
                    }
                    .font(.montserrat(size: 15, weight: .semibold))
                    .foregroundStyle(.red)
                }
            }
        }
        .onAppear {
            refreshTask?.cancel()
            refreshTask = Task {
                while !Task.isCancelled {
                    await fetchCurrentSong()
                    do {
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                    } catch {
                        break
                    }
                }
            }
        }
        .onDisappear {
            refreshTask?.cancel()
            refreshTask = nil
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "waveform.circle")
                    .font(.system(size: 64))
                    .foregroundStyle(color.opacity(0.25))

                VStack(spacing: 8) {
                    Text("No active session")
                        .font(.montserrat(size: 20, weight: .bold))

                    Text("Start a session to take\ncontrol of your queue")
                        .font(.montserrat(size: 15))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(color.opacity(0.5))
                        .lineSpacing(4)
                }
            }

            Spacer()

            StandardButton(label: "Start Session") {
                Task { await startSession() }
            }
            .padding(.horizontal, 20)

            ViewSpacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Active Session

    private var activeSessionView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Live meta row
                HStack(spacing: 6) {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                    Text("Live")
                        .font(.montserrat(size: 13, weight: .bold))
                        .foregroundStyle(.red)
                    Text("·")
                        .foregroundStyle(color.opacity(0.35))
                    Text(sessionTimeString)
                        .font(.montserrat(size: 13))
                        .foregroundStyle(color.opacity(0.5))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

                Divider()
                    .padding(.horizontal, 20)

                // Now Playing
                if let song = currentSong {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("NOW PLAYING")
                            .font(.montserrat(size: 11, weight: .bold))
                            .foregroundStyle(color.opacity(0.4))
                            .tracking(1)

                        HStack(spacing: 12) {
                            ArtworkView(
                                artwork: song.artwork,
                                width: 44,
                                height: 44,
                                cornerRadius: 6
                            )
                            VStack(alignment: .leading, spacing: 3) {
                                Text(song.title)
                                    .font(.montserrat(size: 15, weight: .bold))
                                    .lineLimit(1)
                                Text(song.artistName)
                                    .font(.montserrat(size: 13))
                                    .foregroundStyle(color.opacity(0.6))
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    Divider()
                        .padding(.horizontal, 20)
                }

                // Queue
                VStack(alignment: .leading, spacing: 0) {
                    Text("QUEUE")
                        .font(.montserrat(size: 11, weight: .bold))
                        .foregroundStyle(color.opacity(0.4))
                        .tracking(1)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 10)

                    if sessionManager.sessionQueue.isEmpty {
                        Text("No songs in queue")
                            .font(.montserrat(size: 15))
                            .foregroundStyle(color.opacity(0.35))
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                    } else {
                        ForEach(Array(sessionManager.sessionQueue.enumerated()), id: \.element.id) { index, song in
                            HStack(spacing: 12) {
                                ArtworkView(
                                    artwork: song.artwork,
                                    width: 40,
                                    height: 40,
                                    cornerRadius: 6
                                )
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(song.title)
                                        .font(.montserrat(size: 14, weight: .semibold))
                                        .lineLimit(1)
                                    Text(song.artistName)
                                        .font(.montserrat(size: 12))
                                        .foregroundStyle(color.opacity(0.6))
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)

                            if index < sessionManager.sessionQueue.count - 1 {
                                Divider()
                                    .padding(.leading, 72)
                            }
                        }
                    }
                }

                Divider()
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                // Add Songs placeholder
                StandardButton(
                    label: "+ Add Songs",
                    bgColor: color.opacity(0.08),
                    color: color.opacity(0.35),
                    isDisabled: true
                ) {}
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
    }

    // MARK: - Helpers

    func fetchCurrentSong() async {
        let player = SystemMusicPlayer.shared
        if let entry = player.queue.currentEntry, case .song(let song) = entry.item {
            await MainActor.run { currentSong = song }
        } else {
            await MainActor.run { currentSong = nil }
        }
    }

    func startSession() async {
        let player = SystemMusicPlayer.shared
        var song: Song? = nil
        if let entry = player.queue.currentEntry, case .song(let s) = entry.item {
            song = s
        }
        sessionManager.startSession(currentSong: song)
    }
}
*/
