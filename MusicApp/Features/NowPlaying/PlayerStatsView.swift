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
                        cloudData: cloudData,
                        color: color
                    )
                    
                    Spacer()
                }
            }
            .foregroundStyle(color)
            .background(bgColor)
        }
//        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Stats")
                    .font(.montserrat(size: 17, weight: .bold))
                    .tracking(17 * -0.025)
                    
            }
        }
    }
}
