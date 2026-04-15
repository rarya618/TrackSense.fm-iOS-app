//
//  ClassicLoadingView.swift
//  MusicApp
//
//  Created by Russal Arya on 7/10/2025.
//

import SwiftUI

struct ClassicLoadingView: View {
    let text: String?

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            if let textFromInit = text {
                Text(textFromInit)
                    .font(.montserrat(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
