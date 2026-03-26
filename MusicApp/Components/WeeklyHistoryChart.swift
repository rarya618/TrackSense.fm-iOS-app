import SwiftUI
import Charts

struct WeeklyHistoryChart: View {
    let history: [String : [String : Int]]
    var isSong: Bool = false
    var hasValueProp: Bool = false
    
    // Grouping the data by week
    private var weeklyData: [[(date: String, value: Int)]] {
        let prop = hasValueProp ? "value" : (isSong ? "plays" : "totalPlays")
        let sortedKeys = history.keys.sorted()
        
        // Convert to a flat list of tuples
        let allEntries = sortedKeys.compactMap { dateKey -> (date: String, value: Int)? in
            guard let val = history[dateKey]?[prop] else { return nil }
            return (date: dateKey, value: val)
        }
        
        // Chunk into groups of 7 (one week each)
        return stride(from: 0, to: allEntries.count, by: 7).map {
            Array(allEntries[$0..<min($0 + 7, allEntries.count)])
        }
    }

    var body: some View {
        // Use a TabView with Page style for the "scroll between weeks" feel
        TabView {
            ForEach(0..<weeklyData.count, id: \.self) { index in
                let week = weeklyData[index]
                let values = week.map { $0.value }
                let minValue = (values.min() ?? 0)
                let maxValue = (values.max() ?? 1)
                
                chartForWeek(week: week, min: minValue, max: maxValue)
                    .padding(.horizontal)
            }
        }
        .frame(height: 300)
        .tabViewStyle(.page(indexDisplayMode: .never)) // Enables the paging behavior
    }
    
    @ViewBuilder
    func chartForWeek(week: [(date: String, value: Int)], min: Int, max: Int) -> some View {
        VStack(alignment: .leading) {
            // Optional: Label showing date range for the week
            if let first = week.first?.date, let last = week.last?.date {
                Text("\(first) - \(last)")
                    .font(.caption).bold().foregroundColor(.secondary)
                    .padding(.leading, 10)
            }
            
            Chart {
                ForEach(week, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Plays", item.value)
                    )
                    .interpolationMethod(.catmullRom) // Smoother lines
                    
                    PointMark(
                        x: .value("Date", item.date),
                        y: .value("Plays", item.value)
                    )
                    .annotation(position: .top) {
                        Text("\(item.value)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .chartYAxis { AxisMarks() }
            .chartXAxis {
                AxisMarks(values: week.map { $0.date }) { value in
                    AxisValueLabel() // Shows dates on X axis
                }
            }
            .chartYScale(domain: (min - 2)...(max + 2))
            .frame(height: 270)
        }
    }
}