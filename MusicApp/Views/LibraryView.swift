//
//  LibraryView.swift
//  TrackSense
//
//  Created by Russal Arya on 16/12/2025.
//

import SwiftUI
import MusicKit

struct LibraryView: View {
    let userToken: String
    
    @State private var currentSection = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $currentSection) {
                HomeView(userToken: userToken)
                    .tag(0)
                SongsTabView(userToken: userToken)
                    .tag(1)
                AlbumsTabView(userToken: userToken)
                    .tag(2)
                ArtistsTabView(userToken: userToken)
                    .tag(3)
                PlaylistsTabView(userToken: userToken)
                    .tag(4)
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .frame(maxHeight: .infinity, alignment: .top)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            CustomPicker(
                color: .resonatePurple,
                currentSection: currentSection,
                setCurrentSection: setCurrentSection,
                options: [
                    "Recents",
                    "Songs",
                    "Albums",
                    "Artists",
                    "Playlists"
                ]
            )
            .padding(.vertical, 8)
//            .glassEffect(.regular)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial) // or .regularMaterial
                    .mask(
                        LinearGradient(
                            colors: [.black, .black, .black.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 120) // Adjust based on your toolbar height
            )
//            .shadow(
//                color: Color.black.opacity(0.06),
//                radius: 8,
//                y: 4
//            )
            .animation(.easeInOut(duration: 0.25), value: currentSection)
        }
    }
    
    func setCurrentSection(_ index: Int) {
        currentSection = index
    }
}

