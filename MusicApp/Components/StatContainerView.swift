//
//  StatContainer.swift
//  MusicApp
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
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .fontWeight(.bold)
                    .font(Font.system(size: 22))
                Text(title)
                    .font(Font.system(size: 14))
            }
            Spacer()
        }
        // .foregroundStyle(Color.resonatePurple)
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
    }
}
