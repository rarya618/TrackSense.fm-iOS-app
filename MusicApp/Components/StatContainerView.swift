//
//  StatContainerView.swift
//  Resonate
//
//  Created by Russal Arya on 21/9/2025.
//

import SwiftUI
import MusicKit

struct StatContainerView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.montserrat(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
                Text(title.lowercased())
                    .font(.montserrat(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 13)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.resonatePurple.opacity(0.25))
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
