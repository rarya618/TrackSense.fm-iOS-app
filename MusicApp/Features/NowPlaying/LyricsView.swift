//
//  QueueView.swift
//  Resonate
//
//  Created by Russal Arya on 25/9/2025.
//

import SwiftUI
//import MediaPlayer
import MusicKit

struct QueueView: View {
    let color: Color
    let bgColor: Color
    
    let queue = SystemMusicPlayer.shared.queue

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 32) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 18))
                        
                        Text("Unfortunately, you cannot access the System Queue in Resonate at this time")
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
                .padding(.top, 24)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .background(Color(.red.opacity(0.15)))
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .foregroundStyle(color)
        .background(bgColor)
        .navigationTitle("Next in Queue")
        .navigationBarTitleDisplayMode(.inline)
    }
}
