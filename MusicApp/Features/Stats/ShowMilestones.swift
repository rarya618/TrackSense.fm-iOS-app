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
    
    let color: Color = .customPurple

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
//            Text(title)
//                .font(.montserrat(size: 20, weight: .bold))
//                .foregroundColor(color)

            MilestonesChartView(data: milestoneData)
                .frame(height: 240)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(milestoneData.keys.filter { $0 > 19 }.sorted(by: >), id: \.self) { threshold in
                    let count = milestoneData[threshold, default: 0]
                    let achieved = count > 0

                    HStack(spacing: 4) {
                        Image(systemName: achieved ? "trophy.fill" : "trophy")
                            .font(.montserrat(size: 18, weight: .semibold))
                            .foregroundColor(achieved ? color : .gray)

                        VStack(spacing: 1) {
                            Text(threshold >= 1000 ? "≥ \(threshold/1000)k plays" : "≥ \(threshold) plays")
                                .font(.montserrat(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)

                            Text("\(count)")
                                .font(.montserrat(size: 18, weight: .bold))
                                .foregroundStyle(achieved ? color : .gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                achieved ? color.opacity(0.25) : Color.gray.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .animation(.easeInOut(duration: 0.25), value: achieved)
                }
            }
        }
        .padding(.top, 22)
        .padding(.bottom, 20)
        .padding(.horizontal, 20)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.resonatePurple.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
