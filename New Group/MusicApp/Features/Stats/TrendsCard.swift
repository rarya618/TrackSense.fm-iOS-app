//
//  TrendsCard.swift
//  Resonate
//
//  Created by Russal Arya on 19/11/2025.
//

import SwiftUI
import Charts

struct TrendsCard: View {
    let history: [String: [String: Int]]?
    let unitLabel: String  // "h" or "plays"
    
    private var stats: TrendStats? {
        calculateTrends()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Trends")
                .font(.system(size: 24, weight: .bold))
            
            if let s = stats {
                
                // MARK: - Daily Growth Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Growth")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 14) {
                        TrendMetric(title: "Yesterday",
                                    value: "+\(s.yesterdayGrowth) \(unitLabel)")
                        TrendMetric(title: "7-day Avg",
                                    value: String(format: "%.1f \(unitLabel)/day",
                                                  s.sevenDayAvg))
                        TrendMetric(title: "Peak Day",
                                    value: "+\(s.peakGrowth) \(unitLabel)")
                    }
                    
                    // Sparkline
                    Chart(s.sparklineData) { item in
                        LineMark(
                            x: .value("Day", item.index),
                            y: .value("Growth", item.value)
                        )
                        .interpolationMethod(.catmullRom)
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(height: 40)
                    .padding(.top, 6)
                }
                
                Divider()
                
                // MARK: - Weekly Momentum
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weekly Momentum")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 12) {
                        Text(s.weekTrendIcon)
                            .foregroundStyle(s.weekTrendColor)
                            .font(.title3.weight(.bold))
                        
                        VStack(alignment: .leading) {
                            Text("This Week: +\(s.week1) \(unitLabel)")
                                .font(.headline)
                            Text("Last Week: +\(s.week2) \(unitLabel)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(s.weekPctChange)%")
                            .font(.headline)
                            .foregroundStyle(s.weekTrendColor)
                    }
                }
                
                Divider()
                
                // MARK: - Consistency Score
                VStack(alignment: .leading, spacing: 8) {
                    Text("Consistency")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Text("\(s.consistency)%")
                            .font(.title3.bold())
                        Text(s.consistencyDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                // MARK: - Streaks
                VStack(alignment: .leading, spacing: 8) {
                    Text("Listening Streak")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 18) {
                        TrendMetric(title: "Current", value: "\(s.currentStreak) days")
                        TrendMetric(title: "Longest", value: "\(s.longestStreak) days")
                    }
                }
                
            } else {
                Text("Not enough data to compute trends.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 20)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.resonatePurple.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Helper View
struct TrendMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
    }
}

// MARK: - Trend Stats & Calculation
extension TrendsCard {

    struct TrendStats {
        let daily: [Int]                   // daily growth values
        let yesterdayGrowth: Int
        let sevenDayAvg: Double
        let peakGrowth: Int

        let week1: Int
        let week2: Int
        let weekPctChange: Int
        let weekTrendColor: Color
        let weekTrendIcon: String

        let consistency: Int
        let consistencyDescription: String

        let currentStreak: Int
        let longestStreak: Int

        let sparklineData: [SparkItem]
    }

    struct SparkItem: Identifiable {
        let id = UUID()
        let index: Int
        let value: Int
    }

    // MARK: - Core Calculation
    func calculateTrends() -> TrendStats? {
        guard let history else { return nil }

        // Convert dictionary → sorted array of (Date, totalHours), filling missing days
        let rawTotals: [(date: Date, total: Int)] = history.compactMap { key, val in
            guard let total = val["value"] ?? val["plays"] ?? val["totalPlays"],
                  let date = KeyDateFormatter.date(from: key)
            else { return nil }
            return (date, total)
        }
        .sorted(by: { $0.date < $1.date })

        guard let firstDate = rawTotals.first?.date,
              let lastDate = rawTotals.last?.date
        else { return nil }

        let calendar = Calendar.current
        var totals: [(date: Date, total: Int)] = []
        var cursor = firstDate
        var lastKnownTotal = rawTotals.first!.total
        var index = 0

        while cursor <= lastDate {
            if index < rawTotals.count && calendar.isDate(rawTotals[index].date, inSameDayAs: cursor) {
                lastKnownTotal = rawTotals[index].total
                totals.append((cursor, lastKnownTotal))
                index += 1
            } else {
                // fill missing day using last known cumulative value
                totals.append((cursor, lastKnownTotal))
            }

            cursor = calendar.date(byAdding: .day, value: 1, to: cursor)!
        }

        guard totals.count >= 3 else { return nil }

        // DAILY GROWTH = difference of cumulative totals
        let dailyGrowth = zip(totals.dropFirst(), totals).map { current, previous in
            max(current.total - previous.total, 0)
        }

        guard dailyGrowth.count >= 2 else { return nil }

        let yesterday = dailyGrowth.last ?? 0
        let last7 = Array(dailyGrowth.suffix(7))
        let avg7 = Double(last7.reduce(0, +)) / Double(max(last7.count, 1))
        let peak = dailyGrowth.max() ?? 0

        // Weekly momentum
        let week1 = last7.reduce(0, +)
        let week2 = Array(dailyGrowth.dropLast(7).suffix(7)).reduce(0, +)

        let pct = week2 > 0 ? Int(Double(week1 - week2) / Double(week2) * 100) : 0
        let weekColor: Color = pct >= 0 ? .green : .red
        let weekIcon = pct >= 0 ? "▲" : "▼"

        // Consistency (MAD-based — robust median absolute deviation method)
        let weekValues = last7.map { Double($0) }
        let sortedWeek = weekValues.sorted()
        let median = sortedWeek[sortedWeek.count / 2]

        let deviations = weekValues.map { abs($0 - median) }.sorted()
        let mad = deviations[deviations.count / 2]

        // Relative deviation (normalized variability)
        let relative = mad / max(median, 1)

        // Convert to 0–100 score: lower variability → higher score
        let consistencyScore = max(0, min(100, Int((1 / (1 + relative)) * 100)))

        let consistencyDesc: String = {
            switch consistencyScore {
            case 85...100: return "Very consistent listener"
            case 60..<85:  return "Pretty regular"
            case 30..<60:  return "Some fluctuation"
            default:       return "Listening habits vary a lot"
            }
        }()

        // Streaks
        var longest = 0
        var current = 0
        for v in dailyGrowth {
            if v > 0 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 0
            }
        }

        return TrendStats(
            daily: dailyGrowth,
            yesterdayGrowth: yesterday,
            sevenDayAvg: avg7,
            peakGrowth: peak,
            week1: week1,
            week2: week2,
            weekPctChange: pct,
            weekTrendColor: weekColor,
            weekTrendIcon: weekIcon,
            consistency: consistencyScore,
            consistencyDescription: consistencyDesc,
            currentStreak: current,
            longestStreak: longest,
            sparklineData: dailyGrowth.enumerated().map { SparkItem(index: $0.offset, value: $0.element) }
        )
    }
}

// MARK: - Date Formatter
struct KeyDateFormatter {
    static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    static func date(from string: String) -> Date? {
        formatter.date(from: string)
    }
}
