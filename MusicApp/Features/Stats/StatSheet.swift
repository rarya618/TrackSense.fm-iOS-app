//
//  StatSheet.swift
//  TrackSense
//
//  Created by Russal Arya on 21/11/2025.
//

import SwiftUI

struct StatSheet: View {
    let title: String
    var cloudData: StatFromCloud?
    let historyDescription: String
    let unitLabel: String
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    VStack(alignment: .leading, spacing: 12) {
                        // MARK: - Chart Card
                        ChartCard(
                            title: "History over time",
                            cloudData: cloudData,
                            hasValueProp: true
                        )
                        
                        // MARK: - Description
                        Text(historyDescription)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 24)
                            .padding(.horizontal, 12)
                    }
                    
                    if let cloud = cloudData {
                        VStack(alignment: .leading, spacing: 12) {
                            TrendsCard(
                                history: cloud.history,
                                unitLabel: unitLabel
                            )
                            
                            Text("These insights summarize how your listening habits evolve – including daily growth, weekly momentum, consistency, and streaks – based on your cumulative data.")
                                .font(.montserrat(size: 12))
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 24)
                                .padding(.horizontal, 12)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .foregroundStyle(Color.resonatePurple)
            .background(Color.resonateWhite.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.automatic)
            .presentationCompactAdaptation(.sheet)
        }
    }
}
