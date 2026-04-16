//
//  MilestoneInsightView.swift
//  TrackSense
//
//  Created by Russal Arya on 11/4/2026.
//

import SwiftUI

struct MilestoneInsightView: View {
    var data: [Int: Int]
    
    private var insight: String {
        let total = data.values.max() ?? 1
        let fiftyPlus = data[50] ?? 0
        let percentage = Int(Double(fiftyPlus) / Double(total) * 100)
        return "Nearly \(percentage)% of your library has been played 50+ times. You're a deep listener, not a skipper."
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("insight")
                .font(.montserrat(size: 11, weight: .semibold))
                .foregroundColor(.resonatePurple)
            Text(insight)
                .font(.montserrat(size: 13))
                .foregroundColor(.resonatePurple.opacity(0.8))
        }
        .padding(14)
        .background(Color.resonatePurple.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
