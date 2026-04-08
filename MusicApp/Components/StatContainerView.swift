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
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.montserrat(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
                Text(title.uppercased())
                    .font(.montserrat(size: 12, weight: .semibold))
                    .foregroundStyle(.primary.opacity(0.8))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2))
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
