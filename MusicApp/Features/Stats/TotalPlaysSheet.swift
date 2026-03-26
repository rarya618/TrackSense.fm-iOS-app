//
//  LibraryHoursSheet.swift
//  Resonate
//
//  Created by Russal Arya on 19/11/2025.
//

import SwiftUI

struct LibraryHoursSheet: View {
    var cloudData: LibraryHoursFromCloud?
    
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
                        Text("This chart shows how your total listening hours have changed over time. Data updates when content is synced to the cloud.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 30)
                    }
                    
                    if let cloud = cloudData {
                        TrendsCard(
                            history: cloud.history,
                            unitLabel: "h"
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .foregroundStyle(Color.resonatePurple)
            .background(Color.resonateWhite.ignoresSafeArea())
            .navigationTitle("Library Hours")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.automatic)
            .presentationCompactAdaptation(.sheet)
        }
    }
}
