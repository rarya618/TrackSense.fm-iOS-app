//
//  LibraryStats.swift
//  MusicApp
//
//  Created by Russal Arya on 9/11/2025.
//

import SwiftUI
import MusicKit

struct LibraryStats: View {
    var songs: [Song]
    var albumStats: [AlbumStat]
    var artistStats: [ArtistStat]
    var playlists: MusicItemCollection<Playlist>

    @State private var songsMilestoneData: [Int: Int] = [:]
    @State private var albumsMilestoneData: [Int: Int] = [:]
    @State private var artistsMilestoneData: [Int: Int] = [:]

    @State private var selectedMilestonePage: Int = 0

    // Computed so it stays accurate when songs change, avoids the
    // state-update-inside-loop bug in the previous getLibraryLength().
    private var libraryLength: String {
        let totalSeconds = songs.reduce(0.0) { $0 + ($1.duration ?? 0) }
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds / 60).truncatingRemainder(dividingBy: 60))
        if hours == 0 { return "\(minutes) min" }
        if minutes == 0 { return "\(hours) hrs" }
        return "\(hours) hrs \(minutes) min"
    }

    var body: some View {
        if songs.isEmpty {
            ClassicLoadingView(text: "Loading data")
        } else {
            VStack(spacing: 24) {
                // MARK: - Milestones
                VStack(spacing: 8) {
                    SectionHeader(title: "Milestones", subtitle: "How deep your listening goes")

                    CustomPicker(
                        color: .resonatePurple,
                        currentSection: selectedMilestonePage,
                        setCurrentSection: { selectedMilestonePage = $0 },
                        options: ["Songs", "Albums", "Artists"]
                    )

                    TabView(selection: $selectedMilestonePage) {
                        ShowMilestones(
                            title: "Songs",
                            milestoneData: songsMilestoneData,
                            totalCount: songs.count
                        )
                        .tag(0)

                        ShowMilestones(
                            title: "Albums",
                            milestoneData: albumsMilestoneData,
                            totalCount: albumStats.count
                        )
                        .tag(1)

                        ShowMilestones(
                            title: "Artists",
                            milestoneData: artistsMilestoneData,
                            totalCount: artistStats.count
                        )
                        .tag(2)
                    }
                    .frame(height: 400)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .padding(.top, 8)

                // MARK: - Library Stats
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(
                        title: "Library Stats",
                        subtitle: "Your library at a glance"
                    )

                    VStack(spacing: 10) {
                        StatContainerView(
                            title: "Songs",
                            value: songs.count.formatted(),
                            systemImage: "music.note"
                        )
                        
                        StatContainerView(
                            title: "Albums",
                            value: albumStats.count.formatted(),
                            systemImage: "square.stack.fill"
                        )
                        
                        StatContainerView(
                            title: "Artists",
                            value: artistStats.count.formatted(),
                            systemImage: "person.2.fill"
                        )
                        
                        StatContainerView(
                            title: "Playlists",
                            value: playlists.count.formatted(),
                            systemImage: "list.bullet"
                        )

                        StatContainerView(
                            title: "Library Length",
                            value: libraryLength,
                            systemImage: "clock.fill"
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .task {
                updateSongsMilestones()
                updateAlbumsMilestones()
                updateArtistsMilestones()
            }
            .onChange(of: songs) { _, _ in
                updateSongsMilestones()
            }
            .onChange(of: albumStats) { _, _ in
                updateAlbumsMilestones()
            }
            .onChange(of: artistStats) { _, _ in
                updateArtistsMilestones()
            }
        }
    }

    // MARK: - Milestones

    func calculateMilestones<T>(
        from items: [T],
        playCount: (T) -> Int?
    ) -> [Int: Int] {
        let thresholds = [10, 25, 50, 100, 250, 500, 1000]
        return thresholds.reduce(into: [:]) { result, threshold in
            result[threshold] = items.filter { (playCount($0) ?? 0) >= threshold }.count
        }
    }

    func updateSongsMilestones() {
        songsMilestoneData = calculateMilestones(from: songs) { $0.playCount }
    }

    func updateAlbumsMilestones() {
        albumsMilestoneData = calculateMilestones(from: albumStats) { $0.totalPlayCount }
    }

    func updateArtistsMilestones() {
        artistsMilestoneData = calculateMilestones(from: artistStats) { $0.totalPlayCount }
    }
}
