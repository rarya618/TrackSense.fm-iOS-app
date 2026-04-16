//
//  SongStatsCard.swift
//  Resonate
//
//  Created by Russal Arya on 22/9/2025.
//

import SwiftUI
import MusicKit

struct SongStatsCard: View {
    let song: any SongOrTrack
    var cloudData: SongFromCloud? = nil
    var color: Color = .resonatePurple

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let playCount = song.playCount {
                StatContainerView(
                    title: "Plays",
                    value: playCount.formatted(),
                    color: color,
                    systemImage: "headphones",
                    delta: weeklyDelta(from: cloudData?.history)
                )

                if let duration = song.duration {
                    let totalMinutes = getMinutesPlayed(playCount: playCount, duration: duration)
                    StatContainerView(
                        title: "Minutes",
                        value: Int(totalMinutes).formatted(),
                        color: color,
                        systemImage: "clock.fill"
                    )
                }
            }
            
            if let lastPlayed = song.lastPlayedDate {
                StatContainerView(
                    title: "Last played",
                    value: relativeDate(lastPlayed),
                    color: color,
                    systemImage: "calendar"
                )
            }

            if let discoveredDate = song.libraryAddedDate {
                StatContainerView(
                    title: "Discovered",
                    value: relativeDate(discoveredDate),
                    color: color,
                    systemImage: "star.fill"
                )
            }

            if let releaseDate = song.releaseDate {
                StatContainerView(
                    title: "Release date",
                    value: shortDate(releaseDate),
                    color: color,
                    systemImage: "music.note"
                )
            }

            if let trackNumber = song.trackNumber {
                StatContainerView(
                    title: "Track number",
                    value: trackNumber.formatted(),
                    color: color,
                    systemImage: "number"
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Weekly delta

private func weeklyDelta(from history: [String: [String: Int]]?) -> StatDelta? {
    guard let history else { return nil }

    let rawTotals: [(date: Date, total: Int)] = history.compactMap { key, val in
        guard let total = val["plays"] ?? val["value"] ?? val["totalPlays"],
              let date = KeyDateFormatter.date(from: key)
        else { return nil }
        return (date, total)
    }.sorted { $0.date < $1.date }

    guard rawTotals.count >= 2,
          let firstDate = rawTotals.first?.date,
          let lastDate = rawTotals.last?.date
    else { return nil }

    let calendar = Calendar.current
    var totals: [(Date, Int)] = []
    var cursor = firstDate
    var lastKnown = rawTotals[0].total
    var index = 0

    while cursor <= lastDate {
        if index < rawTotals.count && calendar.isDate(rawTotals[index].date, inSameDayAs: cursor) {
            lastKnown = rawTotals[index].total
            index += 1
        }
        totals.append((cursor, lastKnown))
        guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
        cursor = next
    }

    let dailyGrowth = zip(totals.dropFirst(), totals).map { current, previous in
        max(current.1 - previous.1, 0)
    }

    guard dailyGrowth.count >= 7 else { return nil }

    let thisWeek = Array(dailyGrowth.suffix(7)).reduce(0, +)
    let lastWeek = Array(dailyGrowth.dropLast(7).suffix(7)).reduce(0, +)

    if thisWeek > lastWeek {
        return StatDelta(label: "\(thisWeek) this week", direction: .up)
    } else if thisWeek < lastWeek {
        return StatDelta(label: "\(thisWeek) this week", direction: .down)
    } else {
        return StatDelta(label: "\(thisWeek) this week", direction: .neutral)
    }
}

// MARK: - Date formatting

/// Relative for recent dates, short month+year for older ones.
/// e.g. "Today", "Yesterday", "3 days ago", "2 weeks ago", "Mar 2025"
private func relativeDate(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0

    if calendar.isDateInToday(date)     { return "Today" }
    if calendar.isDateInYesterday(date) { return "Yesterday" }
    if days < 7                         { return "\(days) days ago" }
    if days < 14                        { return "1 week ago" }
    if days < 30                        { return "\(days / 7) weeks ago" }
    if days < 60                        { return "1 month ago" }
    if days < 365                       { return "\(days / 30) months ago" }

    return date.formatted(.dateTime.month(.abbreviated).year())
}

/// Fixed short date format for historical facts.
/// e.g. "15 Jan 2020"
private func shortDate(_ date: Date) -> String {
    date.formatted(.dateTime.day().month(.abbreviated).year())
}

