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
    
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Chart Card
            ChartCard(
                title: "Play History",
                cloudData: cloudData,
                isSong: true
            )
            
            // MARK: - Description
            Text("This chart shows how your plays have changed over time. Data updates when content is synced to the cloud.")
                .font(.footnote)
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
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 24)
                    .padding(.horizontal, 12)
            }
        }
        
        // Stats Card
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats")
                .font(.system(size: 24, weight: .bold))
            SongStatsCard(song: song)
        }
        .padding(.top, 22)
        .padding(.bottom, 20)
        .padding(.horizontal, 20)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.resonatePurple.opacity(0.3), lineWidth: 1)
        )
    }
}

func getMinutesPlayed (playCount: Int, duration: Double) -> Double {
    return (Double(playCount) * duration) / 60
}
