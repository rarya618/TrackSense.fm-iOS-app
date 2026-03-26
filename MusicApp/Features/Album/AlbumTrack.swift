//
//  AlbumTrack.swift
//  Resonate
//
//  Created by Russal Arya on 23/9/2025.
//

import SwiftUI
import MusicKit

struct AlbumTrack: View {
    let track: Track
    // let onTap: () -> Void
    
    var body: some View {
        NavigationLink(destination: TrackView(track: track)) {
        // Button(action: onTap) {
            HStack(spacing: 10) {
                if let trackNumber = track.trackNumber {
                    Text(trackNumber.description)
                        .font(.system(size: 16))
                        .foregroundColor(.resonatePurple)
                }
                
                Text(track.title)
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.resonatePurple)

                Spacer()
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
        }
        .buttonStyle(.plain) // removes SwiftUI’s default button tint
    }
}
