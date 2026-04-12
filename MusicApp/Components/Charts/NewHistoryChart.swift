//
//  NewHistoryChart.swift
//  TrackSense
//
//  Created by Russal Arya on 12/4/2026.
//

import SwiftUI
import Charts
 
struct NewHistoryChart: View {
    let history: [String: [String: Int]]
    var isSong: Bool = false
    var hasValueProp: Bool = false
    var color: Color = .accentColor
    
    // MARK: - Data preparation
    /// All dates from first to last entry, as a flat array
    private var allDates: [(date: Date, value: Int?)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let prop = hasValueProp ? "value" : (isSong ? "plays" : "totalPlays")
        let sortedKeys = history.keys.sorted()
        
        guard
            let firstKey = sortedKeys.first,
            let lastKey = sortedKeys.last,
            let startDate = formatter.date(from: firstKey),
            let endDate = formatter.date(from: lastKey)
        else { return [] }
        
        var result: [(date: Date, value: Int?)] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let dateString = formatter.string(from: currentDate)
            let value = history[dateString]?[prop]
            result.append((date: currentDate, value: value))
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return result
    }
    
    /// Cleaned data with:
    /// - Nils forward-filled from the last known value (total didn't change)
    /// - Downward dips clamped to the previous value (bad Apple data)
    private var cleanedDates: [(date: Date, value: Int?)] {
        var result: [(date: Date, value: Int?)] = []
        var lastValidValue: Int? = nil
        
        for item in allDates {
            if let val = item.value {
                if let last = lastValidValue, val < last {
                    // Dip detected — clamp to last known good value
                    result.append((date: item.date, value: lastValidValue))
                } else {
                    lastValidValue = val
                    result.append((date: item.date, value: val))
                }
            } else {
                // No entry for this day — forward-fill
                result.append((date: item.date, value: lastValidValue))
            }
        }
        
        return result
    }
    
    // MARK: - Scroll state
    /// Tracks the leading edge of the visible 7-day window
    @State private var scrollPosition: Date = Date()
    
    /// The date label shown above the chart, derived from scroll position
    private var visibleRangeLabel: String {
        let end = Calendar.current.date(byAdding: .day, value: 6, to: scrollPosition) ?? scrollPosition
        return "\(scrollPosition.formatted(.dateTime.month().day())) – \(end.formatted(.dateTime.month().day()))"
    }
    
    // MARK: - Y-axis domain
    private var yDomain: ClosedRange<Int> {
        let values = cleanedDates.compactMap { $0.value }
        guard let minVal = values.min(), let maxVal = values.max() else {
            return 0...10
        }
        // Ensure the range is never degenerate (flat line at a single value)
        let padding = max((maxVal - minVal) / 10, 2)
        return max(0, minVal - padding)...(maxVal + padding)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(visibleRangeLabel)
                .font(.montserrat(size: 16, weight: .semibold))
                .padding(.leading, 6)
            // Animate label changes as the user scrolls
                .animation(.easeInOut(duration: 0.2), value: visibleRangeLabel)
            
            Chart {
                ForEach(cleanedDates, id: \.date) { item in
                    if let val = item.value {
                        LineMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Total", val)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(color)
                        
                        AreaMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Total", val)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            .linearGradient(
                                colors: [color.opacity(0.25), color.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        PointMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Total", val)
                        )
                        .foregroundStyle(color)
                        .symbolSize(30)
                        .annotation(position: .top, spacing: 4) {
                            Text("\(val)")
                                .font(.montserrat(size: 10, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartYScale(domain: yDomain)
            .chartYAxis { AxisMarks() }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if value.as(Date.self) != nil {
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
            }
            .chartScrollableAxes(.horizontal)
            // Lock the visible window to exactly 7 days
            .chartXVisibleDomain(length: 7 * 24 * 60 * 60)
            .chartScrollPosition(x: $scrollPosition)
            .frame(height: 270)
        }
        .padding(.horizontal)
        .onAppear {
            // Snap to the most recent 7-day window on load
            if let lastDate = cleanedDates.last?.date {
                scrollPosition = Calendar.current.date(byAdding: .day, value: -6, to: lastDate) ?? lastDate
            }
        }
    }
}
