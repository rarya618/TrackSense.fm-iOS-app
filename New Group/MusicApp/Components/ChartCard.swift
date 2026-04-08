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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal, 20)

            if let cloud = cloudData,
               let history = cloud.history {
                HistoryChart(
                    history: history,
                    isSong: isSong,
                    hasValueProp: hasValueProp
                )
            } else {
                Text("Cloud history unavailable")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.top, 22)
        .padding(.bottom, 20)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.resonatePurple.opacity(0.3), lineWidth: 1)
        )
    }
}
