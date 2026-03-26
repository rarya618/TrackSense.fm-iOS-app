//
//  Card.swift
//  MusicApp
//
//  Created by Russal Arya on 18/11/2025.
//

VStack(alignment: .leading, spacing: 10) {
    Text("Hours Over Time")
        .font(.title2.bold())

    if let cloud = cloudLibraryPlayedHoursData,
       let history = cloud.history {
        HistoryChart(history: history, hasValueProp: true)
            .frame(height: 260)
    } else {
        Text("Cloud history unavailable")
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
.padding(.horizontal, 18)
.padding(.top, 20)
.padding(.bottom, 14)
.background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
