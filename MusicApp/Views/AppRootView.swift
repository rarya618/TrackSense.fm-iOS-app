//
//  AppRootView.swift
//  Resonate
//
//  Created by Russal Arya on 17/9/2025.
//


import SwiftUI
import MusicKit

struct AppRootView: View {
    @AppStorage("isAuthorized") private var isAuthorized: Bool = false
    @State private var userToken: String?
    @State private var isLoading: Bool = true
    
    @State private var isPlayerExpanded = false

    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else if isAuthorized, let token = userToken {
                ZStack(alignment: .bottom) {
                    NavigationStack {
                        HomeView(userToken: token)
                    }
                    .background(Color.resonateLightTurquoise)
                    
                    NowPlayingView(isPlayerExpanded: isPlayerExpanded)
                        .onTapGesture {
                            isPlayerExpanded = true
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                .sheet(isPresented: $isPlayerExpanded) {
                    NowPlayingFullView(isPlayerExpanded: $isPlayerExpanded)
                        .presentationDetents([.large]) // supports swipe
                        .presentationDragIndicator(.visible)
                }
                // .fullScreenCover(isPresented: $isPlayerExpanded) {
                //     NowPlayingFullView(isPlayerExpanded: $isPlayerExpanded)
                // }
            } else {
                AuthView(onAuthorized: { token in
                    self.userToken = token
                    self.isAuthorized = true
                })
            }
        }
        .task {
            await checkAuthorization()
        }
    }
    
    private func checkAuthorization() async {
        // Simulate small delay for splash feel
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let status = MusicAuthorization.currentStatus
        if status == .authorized {
            // You can load stored token from Keychain here
            userToken = UserDefaults.standard.string(forKey: "userToken")
            isAuthorized = userToken != nil
        }
        await MainActor.run { isLoading = false }
    }
}
