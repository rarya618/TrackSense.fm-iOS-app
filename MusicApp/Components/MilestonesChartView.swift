//
//  DonutChartView.swift
//  MusicApp
//
//  Created by Russal Arya on 9/11/2025.
//

import SwiftUI
import Charts

struct DonutChartView: View {
    var data: [Int: Int] // threshold → count

    var body: some View {
        Chart {
            ForEach(data.keys.sorted(), id: \.self) { threshold in
                SectorMark(
                    angle: .value("Count", data[threshold]!),
                    innerRadius: .ratio(0.65),
                    angularInset: 1
                )
                .foregroundStyle(by: .value("Threshold", "≥ \(threshold)"))
            }
        }
        .chartLegend(.visible)
    }
}
