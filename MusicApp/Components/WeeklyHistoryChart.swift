//
//  WeeklyHistoryChart.swift
//  MusicApp
//
//  Created by Russal Arya on 27/2/2026.
//


import SwiftUI
import Charts

struct WeeklyHistoryChart: View {
    let history: [String : [String : Int]]
    var isSong: Bool = false
    var hasValueProp: Bool = false
    
    // Track the current page index
    @State private var selectedWeekIndex: Int = 0
    
    // Updated to use Optional Int to handle missing data without showing 0
    private var weeklyData: [[(date: Date, value: Int?)]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let prop = hasValueProp ? "value" : (isSong ? "plays" : "totalPlays")
        let sortedKeys = history.keys.sorted()
        
        guard let firstKey = sortedKeys.first,
              let lastKey = sortedKeys.last,
              let startDate = formatter.date(from: firstKey),
              let endDate = formatter.date(from: lastKey) else { return [] }
        
        var allDates: [(date: Date, value: Int?)] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let dateString = formatter.string(from: currentDate)
            // If the date isn't in history, 'value' becomes nil
            let value = history[dateString]?[prop]
            allDates.append((date: currentDate, value: value))
            
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return stride(from: 0, to: allDates.count, by: 7).map {
            Array(allDates[$0..<min($0 + 7, allDates.count)])
        }
    }

    var body: some View {
        // Pass the selection binding to the TabView
        TabView(selection: $selectedWeekIndex) {
            ForEach(0..<weeklyData.count, id: \.self) { index in
                let week = weeklyData[index]
                // Filter nils just for calculating the Y-axis range
                let values = week.compactMap { $0.value }
                let minValue = values.min() ?? 0
                let maxValue = values.max() ?? 1
                
                chartForWeek(week: week, min: minValue, max: maxValue)
                    .padding(.horizontal)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 320)
        .onAppear {
            // Automatically jump to the last week when the view opens
            if !weeklyData.isEmpty {
                selectedWeekIndex = weeklyData.count - 1
            }
        }
    }
    
    @ViewBuilder
    func chartForWeek(week: [(date: Date, value: Int?)], min: Int, max: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let start = week.first?.date, let end = week.last?.date {
                Text("\(start.formatted(.dateTime.month().day())) - \(end.formatted(.dateTime.month().day()))")
                    .font(.headline)
                    .padding(.leading, 10)
            }
            
            Chart {
                ForEach(week, id: \.date) { item in
                    // LineMark and PointMark only render if value is not nil
                    if let val = item.value {
                        LineMark(
                            x: .value("Day", item.date),
                            y: .value("Plays", val)
                        )
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Day", item.date),
                            y: .value("Plays", val)
                        )
                        .annotation(position: .top) {
                            Text("\(val)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartYAxis { AxisMarks() }
            .chartXAxis {
                // Stride by day to show all 7 days of the week regardless of data presence
                AxisMarks(values: .stride(by: .day)) { value in
                    if value.as(Date.self) != nil {
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
            }
            // Forces the chart to always show the full 7-day width
            .chartXScale(domain: week.first!.date...week.last!.date)
            .chartYScale(domain: (min - 2)...(max + 2))
            .frame(height: 270)
        }
    }
}
