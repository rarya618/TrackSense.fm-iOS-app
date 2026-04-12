//
//  DottedHistoryChart.swift
//  TrackSense
//
//  Created by Russal Arya on 12/4/2026.
//

import SwiftUI
import Charts

struct DottedHistoryChart: View {
    let history: [String: [String: Int]]
    var isSong: Bool = false
    var hasValueProp: Bool = false
    var color: Color = .accentColor
    
    // MARK: - Data preparation
    private struct ChartPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Int
    }
    
    /// Only days that were actually recorded, with downward dips clamped
    /// to the previous value to correct bad Apple data.
    private var chartPoints: [ChartPoint] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let prop = hasValueProp ? "value" : (isSong ? "plays" : "totalPlays")
        
        return history.keys.sorted().compactMap { key -> ChartPoint? in
            guard
                let date = formatter.date(from: key),
                let value = history[key]?[prop]
            else { return nil }
            return ChartPoint(date: date, value: value)
        }
        .sorted { $0.date < $1.date }
        .reduce(into: [ChartPoint]()) { result, point in
            if let last = result.last, point.value < last.value {
                result.append(ChartPoint(date: point.date, value: last.value))
            } else {
                result.append(point)
            }
        }
    }
    
    // MARK: - Scroll state
    @State private var scrollPosition: Date = Date()
    
    private var visibleRangeLabel: String {
        let end = Calendar.current.date(byAdding: .day, value: 6, to: scrollPosition) ?? scrollPosition
        return "\(scrollPosition.formatted(.dateTime.month().day())) – \(end.formatted(.dateTime.month().day()))"
    }
    
    // MARK: - Y-axis domain (visible window only)
    private var visiblePoints: [ChartPoint] {
        let end = Calendar.current.date(byAdding: .day, value: 6, to: scrollPosition) ?? scrollPosition
        return chartPoints.filter { $0.date >= scrollPosition && $0.date <= end }
    }
    
    private var yDomain: ClosedRange<Int> {
        let values = visiblePoints.map { $0.value }
        guard let minVal = values.min(), let maxVal = values.max() else {
            return 0...10
        }
        let padding = max((maxVal - minVal) / 10, 2)
        return max(0, minVal - padding)...(maxVal + padding)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Date range sits inside the card but acts as a subtle sub-label,
            // not a title — consistent with how milestones card has no internal header
            Text(visibleRangeLabel)
                .font(.montserrat(size: 13, weight: .regular))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .animation(.easeInOut(duration: 0.2), value: visibleRangeLabel)
            
            Chart {
                ForEach(chartPoints) { point in
                    LineMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("Total", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(color)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("Total", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [color.opacity(0.06), color.opacity(0), color.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    PointMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("Total", point.value)
                    )
                    .foregroundStyle(color)
                    .symbolSize(40)
                    .annotation(position: .top, spacing: 6) {
                        Text("\(point.value)")
                            .font(.montserrat(size: 10, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .chartYScale(domain: yDomain)
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if value.as(Date.self) != nil {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(.secondary.opacity(0.3))
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            .foregroundStyle(.secondary)
                            .font(.montserrat(size: 11, weight: .regular))
                    }
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 7 * 24 * 60 * 60)
            .chartScrollPosition(x: $scrollPosition)
            .frame(height: 300)
            .padding(.bottom, 8)
        }
        .onAppear {
            if let lastDate = chartPoints.last?.date {
                scrollPosition = Calendar.current.date(byAdding: .day, value: -6, to: lastDate) ?? lastDate
            }
        }
    }
}
