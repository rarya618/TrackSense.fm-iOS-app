//
//  LyricsView.swift
//  Resonate
//
//  Created by Russal Arya on 26/12/2025.
//

import SwiftUI
//import MediaPlayer
import MusicKit

struct LyricsView: View {
    let color: Color
    let bgColor: Color

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 32) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 18))
                        
                        Text("Lyrics are not available in Resonate at this time")
                            .font(.system(size: 18))
                            .lineSpacing(4)
                    }
                    .foregroundStyle(Color(.red))
                    
                    StandardButton(
                        label: "Open the Music app",
                        bgColor: .red
                    ) {
                        if let url = URL(string: "music://now-playing") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                )
            }
            .padding(.horizontal)
        }
        .foregroundStyle(color)
        .background(bgColor)
        .navigationTitle("Lyrics")
        .navigationBarTitleDisplayMode(.inline)
    }
}
