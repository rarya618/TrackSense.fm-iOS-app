//
//  TotalPlaysStat.swift
//  Resonate
//
//  Created by Russal Arya on 9/11/2025.
//

import SwiftUI

struct TotalPlaysStat: View {
    var totalPlays: Int
    let toggleTotalPlaysSheet: () -> Void

    var body: some View {
        HStack {
            if (totalPlays == 0) {
                // Loading state
                VStack {
                    ClassicLoadingView(text: "Loading total plays")
                }
            } else {
                VStack (alignment: .leading, spacing: 16) {
                    HStack (alignment: .top) {
                        VStack (alignment: .leading, spacing: 2) {
                            Text(totalPlays.formatted())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color.customPurple)

                            Text("times played")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.customLightPurple)
                        }

                        Spacer()

                        Button(action: {
                            toggleTotalPlaysSheet()
                        }) {
                            HStack {
                                Image(systemName: "chart.xyaxis.line")
                                    .font(.system(size: 18))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 10)
                            .foregroundColor(.resonatePurple)
                            .background(
                                Capsule()
                                    .fill(Color.resonatePurple.opacity(0.12))
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Text({
                        let s = AttributedString("According to your Apple Music data ")
                        return s
                    }())
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.customLightPurple)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.resonatePurple.opacity(0.3), lineWidth: 1)
        )
    }
}
