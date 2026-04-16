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
    let song: Song?
    let color: Color
    let bgColor: Color

    var body: some View {
        ZStack {
            ScrollView() {
                if let song = song {
                    SongLyricsView(song: song, color: color)
                        .padding(.horizontal)
                        .padding(.vertical, 24)
                    
                    Spacer()
                }
            }
            .foregroundStyle(color)
            .background(bgColor)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
