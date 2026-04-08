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
    
    @State private var libraryLengthHours: Int = 0
    
    func setCurrentSection(_ index: Int) {
        selectedMilestonePage = index
    }

    var body: some View {
        if songs.isEmpty {
            ClassicLoadingView(text: "Loading data")
        } else {
            VStack(spacing: 6) {
                VStack(spacing: 8) {
                    SectionHeader(title: "Milestones", subtitle: "Track your listening milestones")
                    
                    CustomPicker(
                        color: .resonatePurple,
                        currentSection: selectedMilestonePage,
                        setCurrentSection: setCurrentSection,
                        options: [
                            "Songs",
                            "Albums",
                            "Artists"
                        ]
                    )
                    
                    TabView(selection: $selectedMilestonePage) {
                        ShowMilestones(
                            title: "Songs",
                            milestoneData: songsMilestoneData
                        )
                            .tag(0)
                        ShowMilestones(
                            title: "Albums",
                            milestoneData: albumsMilestoneData
                        )
                            .tag(1)
                        ShowMilestones(
                            title: "Artists",
                            milestoneData: artistsMilestoneData
                        )
                            .tag(2)
                    }
                    .frame(height: 420)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Library Stats")
                        .font(.montserrat(size: 22, weight: .bold))
                    
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            StatContainerView(title: "Artists", value: artistStats.count.formatted())
                            StatContainerView(title: "Albums", value: albumStats.count.formatted())
                        }
                        HStack(spacing: 6) {
                            StatContainerView(title: "Songs", value: songs.count.formatted())
                            StatContainerView(title: "Playlists", value: playlists.count.formatted())
                        }
                        
                        StatContainerView(title: "Library Length", value: "\(libraryLengthHours) hours")
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 22)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.resonatePurple.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.top, 20)

            }
            .task {
                getLibraryLength()
                
                updateSongsMilestones()
                updateAlbumsMilestones()
                updateArtistsMilestones()
            }
            .onChange(of: songs) { oldValue, newValue in
                getLibraryLength()
                updateSongsMilestones()
            }
            .onChange(of: albumStats) { oldValue, newValue in
                updateAlbumsMilestones()
            }
            .onChange(of: artistStats) { oldValue, newValue in
                updateArtistsMilestones()
            }
        }
    }
    
    func getLibraryLength() {
        var total: Double = 0

        for song in songs {
            if let duration = song.duration {
                total += duration
            }
            
            libraryLengthHours = Int((total / 60) / 60)
        }
    }
    
    func calculateMilestones<T>(
        from items: [T],
        playCount: (T) -> Int?
    ) -> [Int: Int] {
        let thresholds = [10, 25, 50, 100, 250, 500, 1000]
        var data: [Int: Int] = [:]

        for threshold in thresholds {
            data[threshold] = items.filter { (playCount($0) ?? 0) >= threshold }.count
        }

        return data
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
