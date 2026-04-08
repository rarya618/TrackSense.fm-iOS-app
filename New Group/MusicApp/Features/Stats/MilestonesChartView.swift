//
//  MilestonesChartView.swift
//  Resonate
//
//  Created by Russal Arya on 9/11/2025.
//

import SwiftUI
import Charts

struct MilestonesChartView: View {
    var data: [Int: Int] // threshold → count

    var body: some View {
        let exclusiveData = makeExclusiveBins(from: data)
                
        Chart {
            ForEach(exclusiveData, id: \.label) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.6)
                )
                .foregroundStyle(by: .value("Range", item.label))
                .annotation(position: .overlay) {
                    Text("\(item.count)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .shadow(radius: 1)
                }
            }
        }
        .chartLegend(.visible)
    }
}

func makeExclusiveBins(from cumulativeData: [Int: Int]) -> [(label: String, count: Int)] {
    let sortedThresholds = cumulativeData.keys.sorted()
    var exclusive: [(String, Int)] = []
    
    for (index, threshold) in sortedThresholds.enumerated() {
        let current = cumulativeData[threshold] ?? 0
        let next = index + 1 < sortedThresholds.count
            ? (cumulativeData[sortedThresholds[index + 1]] ?? 0)
            : 0
        
        let rangeCount = current - next
        let label: String
        if index + 1 < sortedThresholds.count {
            label = "\(threshold)–\(sortedThresholds[index + 1] - 1)"
        } else {
            label = "≥\(threshold)"
        }
        
        exclusive.append((label, max(rangeCount, 0)))
    }
    
    return exclusive
}
