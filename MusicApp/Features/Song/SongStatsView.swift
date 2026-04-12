//
//  SongStatsView.swift
//  Resonate
//
//  Created by Russal Arya on 22/9/2025.
//

import SwiftUI
import MusicKit

struct SongStatsView: View {
    let song: Song
    let cloudData: SongFromCloud?
    var color = Color.resonatePurple
    
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Chart Card
            ChartCard(
                title: "Play History",
                cloudData: cloudData,
                isSong: true,
                color: color
            )
            
            // MARK: - Description
            Text("This chart shows how your plays have changed over time. Data updates when content is synced to the cloud.")
                .font(.montserrat(size: 13))
                .lineSpacing(4)
                .foregroundStyle(.secondary)
                .padding(.bottom, 18)
                .padding(.horizontal, 12)
        }
        
        if let cloud = cloudData {
            VStack(alignment: .leading, spacing: 12) {
                TrendsCard(
                    history: cloud.history,
                    unitLabel: "plays"
                )
                
                Text("These insights summarize how your listening habits evolve – including daily growth, weekly momentum, consistency, and streaks – based on your cumulative data.")
                    .font(.montserrat(size: 13))
                    .lineSpacing(4)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 24)
            }
            .padding(.horizontal)
        }
        
        // Stats Card
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "Stats",
                subtitle: "See your song stats in a glance"
            )
            SongStatsCard(song: song)
                .padding(.horizontal)
        }
    }
}

func getMinutesPlayed (playCount: Int, duration: Double) -> Double {
    return (Double(playCount) * duration) / 60
}
