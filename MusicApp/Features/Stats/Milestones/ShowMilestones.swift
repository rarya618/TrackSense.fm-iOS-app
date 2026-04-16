//
//  ShowMilestones.swift
//  Resonate
//
//  Created by Russal Arya on 9/11/2025.
//

import SwiftUI

struct ShowMilestones: View {
    let title: String
    var milestoneData: [Int: Int]
    let totalCount: Int
    
    let color: Color = .customPurple

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            MilestonesChartView(
                data: milestoneData,
                totalCount: totalCount
            )
                .frame(height: 360)
        }
        .padding(.top, 14)
        .padding(.bottom, 10)
        .padding(.leading, 10)
        .padding(.trailing, 12)
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.resonatePurple.opacity(0.3), lineWidth: 1)
        )
//        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}
