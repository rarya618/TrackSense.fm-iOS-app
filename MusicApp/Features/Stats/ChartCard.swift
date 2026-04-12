//
//  ChartCard.swift
//  Resonate
//
//  Created by Russal Arya on 18/11/2025.
//

import SwiftUI

struct ChartCard<T: CloudDecodable>: View {
    let title: String
    let cloudData: T?
    var isSong: Bool = false
    var hasValueProp: Bool = false
    var color = Color.resonatePurple
    
    var subtitle: String = "How your plays have changed"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(
                title: title,
                subtitle: subtitle
            )
            
            if let cloud = cloudData,
               let history = cloud.history {
                HistoryChart(
                    history: history,
                    isSong: isSong,
                    hasValueProp: hasValueProp,
                    color: color
                )
            } else {
                Text("Cloud history unavailable")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
        }
    }
}
