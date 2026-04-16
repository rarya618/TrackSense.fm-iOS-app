//
//  MilestonesChartView.swift
//  TrackSense
//
//  Created by Russal Arya on 9/11/2025.
//

import SwiftUI
import Charts

struct MilestonesChartView: View {
    var data: [Int: Int] // threshold → count
    let totalCount: Int
    
    private var sortedData: [(threshold: Int, count: Int)] {
        data.keys.sorted().compactMap { key in
            guard let count = data[key] else { return nil }
            return (threshold: key, count: count)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(sortedData, id: \.threshold) { item in
                MilestoneRow(
                    threshold: item.threshold,
                    count: item.count,
                    total: totalCount
                )
            }
        }
    }
}

struct MilestoneRow: View {
    let threshold: Int
    let count: Int
    let total: Int
    
    let barHeight: CGFloat = 12
    let textWidth: CGFloat = 80
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    private var percentageText: String {
        "\(Int(percentage * 100))% of your library"
    }
    
    private var isRare: Bool {
        percentage < 0.05
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                // Label
                Text("≥ \(formattedThreshold) plays")
                    .font(.montserrat(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: textWidth, alignment: .trailing)
                
                // Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Track
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: barHeight)
                        
                        // Fill
                        RoundedRectangle(cornerRadius: 6)
                            .fill(barColor)
                            .frame(width: geo.size.width * percentage, height: barHeight)
                    }
                }
                .frame(height: barHeight)
                
                // Value outside bar
                Text("\(count)")
                    .font(.montserrat(size: 14, weight: .semibold))
                    .foregroundColor(.resonatePurple)
                    .frame(width: 48)
            }
            
            // Annotation
            HStack {
                Spacer().frame(width: textWidth + 12)
                if isRare {
                    HStack(spacing: 6) {
                        Text(percentageText)
                            .font(.montserrat(size: 12, weight: .semibold))
                            .foregroundColor(.resonatePurple)
                        Text("top \(Int(percentage * 100))%")
                            .font(.montserrat(size: 10, weight: .bold))
                            .foregroundColor(.resonateWhite)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.resonatePurple)
                            .clipShape(Capsule())
                    }
                } else {
                    Text(percentageText)
                        .font(.montserrat(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.bottom, 10)
    }
    
    private var barColor: Color {
        switch percentage {
        case 0.3...: return Color.resonatePurple
        case 0.1..<0.3: return Color.resonatePurple.opacity(0.85)
        case 0.05..<0.1: return Color.resonatePurple.opacity(0.7)
        case 0.02..<0.05: return Color.resonatePurple.opacity(0.55)
        default: return Color.resonatePurple.opacity(0.4)
        }
    }
    
    private var formattedThreshold: String {
        threshold >= 1000 ? "\(threshold / 1000)k" : "\(threshold)"
    }
}
