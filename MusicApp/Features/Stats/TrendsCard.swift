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
    var color: Color = .resonatePurple

    private var stats: TrendStats? {
        calculateTrends()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Trends",
                subtitle: "How your listening habits evolve",
                hasLeadingPadding: false
            )

            if let s = stats {

                // MARK: - Sparkline Card
                TrendSectionCard(color: color) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Daily Growth")
                            .font(.montserrat(size: 12, weight: .semibold))
                            .tracking(12 * -0.02)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)

                        // Sparkline with area fill
                        Chart(s.sparklineData) { item in
                            AreaMark(
                                x: .value("Day", item.index),
                                y: .value("Growth", item.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [color.opacity(0.35), color.opacity(0.04)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            LineMark(
                                x: .value("Day", item.index),
                                y: .value("Growth", item.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(color)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .frame(height: 72)

                        // Metrics row
                        HStack(spacing: 0) {
                            TrendMetric(
                                title: "Yesterday",
                                value: "+\(s.yesterdayGrowth) \(unitLabel)"
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Rectangle()
                                .fill(color.opacity(0.2))
                                .frame(width: 1, height: 30)

                            TrendMetric(
                                title: "7-Day Avg",
                                value: String(format: "%.1f \(unitLabel)/day", s.sevenDayAvg)
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 14)

                            Rectangle()
                                .fill(color.opacity(0.2))
                                .frame(width: 1, height: 30)

                            TrendMetric(
                                title: "Peak Day",
                                value: "+\(s.peakGrowth) \(unitLabel)"
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 14)
                        }
                    }
                }

                // MARK: - Weekly + Streak row
                HStack(spacing: 12) {

                    // Weekly Momentum
                    TrendSectionCard(color: color) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Weekly")
                                .font(.montserrat(size: 12, weight: .semibold))
                                .tracking(12 * -0.02)
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)

                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(s.weekTrendIcon)
                                    .font(.montserrat(size: 14, weight: .bold))
                                    .foregroundStyle(s.weekTrendColor)
                                Text("\(abs(s.weekPctChange))%")
                                    .font(.montserrat(size: 26, weight: .bold))
                                    .tracking(26 * -0.025)
                                    .foregroundStyle(s.weekTrendColor)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text("This week: \(s.week1) \(unitLabel)")
                                    .font(.montserrat(size: 13, weight: .medium))
                                    .tracking(13 * -0.025)
                                Text("Last week: \(s.week2) \(unitLabel)")
                                    .font(.montserrat(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }

                    // Streak
                    TrendSectionCard(color: color) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Streak")
                                .font(.montserrat(size: 12, weight: .semibold))
                                .tracking(12 * -0.02)
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)

                            Spacer()

                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(s.currentStreak)")
                                    .font(.montserrat(size: 26, weight: .bold))
                                    .tracking(26 * -0.025)
                                    .foregroundStyle(.primary)
                                Text("days")
                                    .font(.montserrat(size: 14, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }

                            Text("Best: \(s.longestStreak) days")
                                .font(.montserrat(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                }

                // MARK: - Consistency
                TrendSectionCard(color: color) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Consistency")
                                .font(.montserrat(size: 12, weight: .semibold))
                                .tracking(12 * -0.02)
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)

                            Spacer()

                            Text("\(s.consistency)%")
                                .font(.montserrat(size: 18, weight: .bold))
                                .tracking(18 * -0.025)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(color.opacity(0.15))
                                    .frame(height: 7)

                                Capsule()
                                    .fill(color)
                                    .frame(width: geo.size.width * CGFloat(s.consistency) / 100, height: 7)
                            }
                        }
                        .frame(height: 7)

                        Text(s.consistencyDescription)
                            .font(.montserrat(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }

            } else {
                Text("Not enough data to compute trends.")
                    .font(.montserrat(size: 14))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Card Container
private struct TrendSectionCard<Content: View>: View {
    var color: Color = .resonatePurple
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding()
            .background(color.opacity(0))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.25), lineWidth: 1)
            )
    }
}

// MARK: - Helper View
struct TrendMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.montserrat(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Text(value)
                .font(.montserrat(size: 14, weight: .bold))
                .tracking(14 * -0.025)
                .lineLimit(1)
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
        var lastKnownTotal = rawTotals[0].total
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

            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
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

        // Consistency (MAD-based)
        let weekValues = last7.map { Double($0) }
        let sortedWeek = weekValues.sorted()

        // Correct median for any array length
        let mid = sortedWeek.count / 2
        let median = sortedWeek.count % 2 == 0
            ? (sortedWeek[mid - 1] + sortedWeek[mid]) / 2.0
            : sortedWeek[mid]

        // No listens = no meaningful consistency score
        guard median > 0 else {
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
                consistency: 0,
                consistencyDescription: "No listening data",
                currentStreak: current,
                longestStreak: longest,
                sparklineData: dailyGrowth.enumerated().map { SparkItem(index: $0.offset, value: $0.element) }
            )
        }

        // Correct MAD median
        let deviations = weekValues.map { abs($0 - median) }.sorted()
        let madMid = deviations.count / 2
        let mad = deviations.count % 2 == 0
            ? (deviations[madMid - 1] + deviations[madMid]) / 2.0
            : deviations[madMid]

        let relative = mad / median
        let consistencyScore = max(0, min(100, Int((1 / (1 + relative)) * 100)))

        let consistencyDesc: String = {
            switch consistencyScore {
            case 85...100: return "Very consistent listener"
            case 60..<85:  return "Pretty regular"
            case 30..<60:  return "Some fluctuation"
            default:       return "Listening habits vary a lot"
            }
        }()

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
