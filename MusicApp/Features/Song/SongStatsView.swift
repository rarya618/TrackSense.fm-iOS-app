//
//  SongStatsView.swift
//  Resonate
//
//  Created by Russal Arya on 22/9/2025.
//

import SwiftUI
import MusicKit

struct SongStatsView: View {
    let song: any SongOrTrack
    let cloudData: SongFromCloud?
    var color = Color.resonatePurple

    private var maybeSong: Song? { song as? Song }

    @State private var currentSection: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CustomPicker(
                color: color,
                currentSection: currentSection,
                setCurrentSection: { currentSection = $0 },
                options: ["Stats", "Insights", "Lyrics", "Credits"]
            )
            .padding(.bottom, 20)
            
            if currentSection == 0 {
                // MARK: - Stats
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(
                            title: "Stats",
                            subtitle: "Your listening stats at a glance"
                        )
                        SongStatsCard(song: song, cloudData: cloudData, color: color)
                            .padding(.horizontal)
                    }
                    
                    AudioQualityCard(
                        isAppleDigitalMaster: maybeSong?.isAppleDigitalMaster,
                        audioVariants: maybeSong?.audioVariants,
                        color: color
                    )
                }
            } else if currentSection == 1 {
                // MARK: - Insights
                if let cloud = cloudData {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            ChartCard(
                                title: "History over time",
                                cloudData: cloud,
                                isSong: true,
                                color: color,
                                subtitle: "How your plays have changed"
                            )
                            Text("Data updates when content is synced to the cloud.")
                                .font(.montserrat(size: 13))
                                .lineSpacing(4)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            TrendsCard(
                                history: cloud.history,
                                unitLabel: "plays",
                                color: color
                            )
                            .padding(.horizontal)
                            Text("Includes daily growth, weekly momentum, consistency, and streaks based on your cumulative data.")
                                .font(.montserrat(size: 13))
                                .lineSpacing(4)
                                .foregroundStyle(.secondary)
                                .padding(.top, 6)
                                .padding(.bottom, 24)
                                .padding(.horizontal)
                        }
                    }
                } else {
                    // MARK: - Insights empty state
                    VStack(spacing: 12) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 36))
                            .foregroundStyle(color.opacity(0.4))
                        
                        Text("No insights yet")
                            .font(.montserrat(size: 16, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Text("Keep listening and sync your data to see trends and play history here.")
                            .font(.montserrat(size: 14))
                            .lineSpacing(4)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 48)
                }
            } else if currentSection == 2 {
                // MARK: - Lyrics
                SongLyricsView(song: song, color: color)
                    .padding(.horizontal)
            } else {
                // MARK: - Credits
                SongCreditsView(song: song, color: color)
                    .padding(.horizontal)
            }
        }
    }
}

func getMinutesPlayed(playCount: Int, duration: Double) -> Double {
    return (Double(playCount) * duration) / 60
}
