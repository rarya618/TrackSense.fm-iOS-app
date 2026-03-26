//
//  PlayerStatsView.swift
//  Resonate
//
//  Created by Russal Arya on 9/11/2025.
//

import SwiftUI
import MusicKit

struct PlayerStatsView: View {
    let song: Song?
    let cloudData: SongFromCloud?
    let setOverlayMessage: (String?) -> Void
    let setErrorMessage: (String?) -> Void
    let color: Color
    let bgColor: Color
    
    var body: some View {
        ZStack {
            ScrollView() {
                if let song = song {
                    SongStatsView(
                        song: song,
                        cloudData: cloudData
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .foregroundStyle(color)
            .background(bgColor)
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }
}
