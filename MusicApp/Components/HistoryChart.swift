//
//  HistoryChart.swift
//  Resonate
//
//  Created by Russal Arya on 16/11/2025.
//

import SwiftUI
import Charts
import FirebaseDatabase
import MusicKit

struct SongFromCloud: Codable {
    let title: String
    let artistName: String
    let albumTitle: String
    let plays: Int
    let lastPlayedDate: String?
    let history: [String: [String: Int]]?

    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else { return nil }
        self.title = dict["title"] as? String ?? ""
        self.artistName = dict["artistName"] as? String ?? ""
        self.albumTitle = dict["albumTitle"] as? String ?? ""
        self.plays = dict["plays"] as? Int ?? 0
        self.lastPlayedDate = dict["lastPlayedDate"] as? String ?? nil
        self.history = dict["history"] as? [String: [String: Int]]
    }
}

struct AlbumFromCloud: Codable {
    let title: String
    let artistName: String
    let plays: Int
    let history: [String: [String: Int]]?

    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else { return nil }
        self.title = dict["title"] as? String ?? ""
        self.artistName = dict["artistName"] as? String ?? ""
        self.plays = dict["plays"] as? Int ?? 0
        self.history = dict["history"] as? [String: [String: Int]]
    }
}

struct ArtistFromCloud: Codable {
    let name: String
    let plays: Int
    let history: [String: [String: Int]]?

    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else { return nil }
        self.name = dict["name"] as? String ?? ""
        self.plays = dict["plays"] as? Int ?? 0
        self.history = dict["history"] as? [String: [String: Int]]
    }
}

struct StatFromCloud: Codable {
    let value: Int
    let history: [String: [String: Int]]?

    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else { return nil }
        self.value = dict["value"] as? Int ?? 0
        self.history = dict["history"] as? [String: [String: Int]]
    }
}

// Protocol for decoding from DataSnapshot
protocol CloudDecodable {
    var history: [String: [String: Int]]? { get }
    
    init?(snapshot: DataSnapshot)
}

extension SongFromCloud: CloudDecodable {}
extension AlbumFromCloud: CloudDecodable {}
extension ArtistFromCloud: CloudDecodable {}
extension StatFromCloud: CloudDecodable {}

/// Fetch any item (song/album/artist) from Realtime Database
func getItemFromDatabase<T: CloudDecodable>(
    id: MusicItemID,
    userID: String,
    type: String,
    showError: @escaping (String) async -> Void
) async -> T? {

    let safeId = sanitizeId(id.rawValue)
    let path = setPath(userID: userID, type: type, id: safeId)

    do {
        let snapshot = try await Database.database().reference()
            .child(path)
            .getData()

        guard snapshot.exists() else {
            await showError("Item not found in Cloud")
            return nil
        }

        guard let item = T(snapshot: snapshot) else {
            await showError("Invalid \(type) format")
            return nil
        }

        return item
    } catch {
        await showError("Failed to fetch \(type)")
        return nil
    }
}

struct HistoryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

//extension HistoryChart {
//    private func processHistory() -> [HistoryEntry] {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd" // Adjust if your keys use a different format
//        
//        let prop = hasValueProp ? "value" : (isSong ? "plays" : "totalPlays")
//        
//        return history.compactMap { (key, value) in
//            guard let date = formatter.date(from: key),
//                  let count = value[prop] else { return nil }
//            return HistoryEntry(date: date, count: count)
//        }.sorted(by: { $0.date < $1.date })
//    }
//}

//struct HistoryChart: View {
//    let history: [String : [String : Int]]
//    var isSong: Bool = false
//    var hasValueProp: Bool = false
//    
//    // Apple Health typically uses a vibrant blue or pink for Trends
//    let chartColor = Color.blue
//
//    var body: some View {
//        let data = processHistory()
//        let maxPlayCount = data.map { $0.count }.max() ?? 10
//        
//        VStack(alignment: .leading, spacing: 16) {
//            chartHeader(latestCount: data.last?.count ?? 0)
//
//            Chart {
//                ForEach(data) { entry in
//                    // The main trend line
//                    LineMark(
//                        x: .value("Day", entry.date, unit: .day),
//                        y: .value("Plays", entry.count)
//                    )
//                    .interpolationMethod(.catmullRom) // Smooths the line like Apple Health
//                    .foregroundStyle(chartColor)
//                    .lineStyle(StrokeStyle(lineWidth: 3))
//
//                    // Area gradient underneath the line
//                    AreaMark(
//                        x: .value("Day", entry.date, unit: .day),
//                        y: .value("Plays", entry.count)
//                    )
//                    .interpolationMethod(.catmullRom)
//                    .foregroundStyle(
//                        LinearGradient(
//                            gradient: Gradient(colors: [chartColor.opacity(0.4), chartColor.opacity(0.0)]),
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                    )
//                }
//            }
//            // 1. Enables horizontal scrolling
//            .chartScrollableAxes(.horizontal)
//            // 2. Sets the "Visible" window (e.g., show 7 days at a time)
//            .chartXVisibleDomain(length: 3600 * 24 * 7)
//            .chartXAxis {
//                AxisMarks(values: .stride(by: .day)) { value in
//                    if let date = value.as(Date.self) {
//                        // Shows single letter day (M, T, W...)
//                        AxisValueLabel(format: .dateTime.weekday(.narrow))
//                    }
//                    AxisGridLine()
//                    AxisTick()
//                }
//            }
//            .chartYAxis {
//                AxisMarks(position: .leading)
//            }
//            .chartYScale(domain: 0...(maxPlayCount + 2))
//            .frame(height: 250)
//        }
//        .padding()
//        .background(Color(.secondarySystemBackground))
//        .cornerRadius(12)
//    }
//
//    // Header matching Apple Health style
//    private func chartHeader(latestCount: Int) -> some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text("PLAY HISTORY")
//                .font(.caption.bold())
//                .foregroundStyle(.secondary)
//            Text("\(latestCount)")
//                .font(.montserrat(.title, design: .rounded).bold()) +
//            Text(" plays today")
//                .font(.callout)
//                .foregroundStyle(.secondary)
//        }
//    }
//
//    private func processHistory() -> [HistoryEntry] {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let prop = hasValueProp ? "value" : (isSong ? "plays" : "totalPlays")
//        
//        return history.compactMap { (key, value) in
//            guard let date = formatter.date(from: key),
//                  let count = value[prop] else { return nil }
//            return HistoryEntry(date: date, count: count)
//        }.sorted(by: { $0.date < $1.date })
//    }
//}

//struct HistoryChart: View {
//    let history: [String : [String : Int]]
//    var isSong: Bool = false
//    var hasValueProp: Bool = false
//    
//    // Apple-like styling constants
//    let barColor = Color.blue // Apple Health uses specific colors for types
//    
//    var body: some View {
//        let data = processHistory()
//        
//        VStack(alignment: .leading) {
//            // Summary Header (Typical of Apple Health)
//            if let total = data.map({$0.count}).last {
//                VStack(alignment: .leading) {
//                    Text("LATEST DAY")
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                    Text("\(total) \((isSong ? "plays" : "hours"))")
//                        .font(.title2.bold())
//                }
//                .padding(.horizontal)
//            }
//
//            Chart {
//                ForEach(data) { entry in
//                    BarMark(
//                        x: .value("Day", entry.date, unit: .day),
//                        y: .value("Plays", entry.count),
//                        width: .fixed(12) // Thinner bars like Apple Health
//                    )
//                    .foregroundStyle(barColor.gradient)
//                    .cornerRadius(4)
//                }
//            }
//            .chartXAxis {
//                // Shows M, T, W, T, F, S, S
//                AxisMarks(values: .stride(by: .day)) { value in
//                    AxisValueLabel(format: .dateTime.weekday(.narrow))
//                }
//            }
//            .chartYAxis {
//                AxisMarks(position: .leading)
//            }
//            // Logic to restrict view to 7 days (the "Weekly" look)
//            .chartXScale(domain: Calendar.current.date(byAdding: .day, value: -6, to: Date())!...Date())
//            .frame(height: 240)
//            .padding()
//        }
//        .background(Color(.systemBackground))
//    }
//}

struct HistoryChart: View {
    let history: [String : [String : Int]]
    var isSong: Bool = false
    var hasValueProp: Bool = false
    
    var body: some View {
        WeeklyHistoryChart(history: history, isSong: isSong, hasValueProp: hasValueProp)
//        let prop = hasValueProp ? "value" : (isSong ? "plays" : "totalPlays")
//        let allValues = history.values.compactMap { $0[prop] }
//        let minValue = (allValues.min() ?? 0)
//        let maxValue = (allValues.max() ?? 1)
//        
//        ScrollViewReader { proxy in
//            ScrollView(.horizontal, showsIndicators: false) {
//                Chart {
//                    ForEach(history.keys.sorted(), id: \.self) { dateKey in
//                        if let playInfo = history[dateKey],
//                           let playCount = playInfo[prop] {
//                            LineMark(
//                                x: .value("Date", dateKey),
//                                y: .value("Plays", playCount)
//                            )
//                            
//                            PointMark(
//                                x: .value("Date", dateKey),
//                                y: .value("Plays", playCount)
//                            )
//                            .annotation(position: .leading) {
//                                Text("\(playCount)")
//                                    .font(.caption2)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                }
//                .chartYAxis { AxisMarks() }
//                .chartXAxis { AxisMarks(values: history.keys.sorted()) }
//                .chartYScale(domain: (minValue - 2)...(maxValue + 2))
//                .frame(width: CGFloat(50 * history.count), height: 270)
//                .padding(.horizontal, 20)
//                .id("chartEnd")
//            }
//            .frame(height: 270)
//            .onAppear {
//                withAnimation(.easeOut(duration: 0.35)) {
//                    proxy.scrollTo("chartEnd", anchor: .trailing)
//                }
//            }
//        }
    }
}
