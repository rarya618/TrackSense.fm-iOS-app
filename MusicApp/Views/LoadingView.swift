//
//  LoadingView.swift
//  TrackSense
//
//  Created by Russal Arya on 17/9/2025.
//

import SwiftUI
import MusicKit

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.resonateWhite.ignoresSafeArea()
            VStack(spacing: 16) {
                Image("AppIconImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
            }
        }
    }
}
