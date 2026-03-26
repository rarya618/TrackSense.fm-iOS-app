//
//  TotalPlaysSheet 2.swift
//  MusicApp
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
                    VStack(alignment: .leading, spacing: 18) {
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
                            .padding(.bottom, 30)
                    }
                    
                    if let cloud = cloudData {
                        TrendsCard(
                            history: cloud.history,
                            unitLabel: unitLabel
                        )
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
