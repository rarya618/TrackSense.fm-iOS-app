//
//  AuthView.swift
//  TrackSense
//
//  Created by Russal Arya on 17/9/2025.
//

import SwiftUI
import MusicKit

struct TextItem: View {
    let text: String
    
    var body: some View {
        Text(text)
            .multilineTextAlignment(.leading)
            .foregroundColor(.secondary)
            .padding(.horizontal)
    }
}

struct AuthView: View {
    var onAuthorized: (String) -> Void
    
    @State private var status: MusicAuthorization.Status = .notDetermined
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var userToken: String?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                NoteFromMeView()
                    .padding(.horizontal)
                    .padding(.top, 70)
                    .padding(.bottom, 120)
            }
            .ignoresSafeArea()
            
            StandardButton(
                label: "Get started",
                action: {
                    Task {
                        await authorizeAndFetchToken()
                    }
                }
            )
            .padding(.horizontal)
        }
    }

    // Handle full flow
    func authorizeAndFetchToken() async {
        await MainActor.run { self.isLoading = true }
        await MainActor.run { self.errorMessage = nil }

        let newStatus = await MusicAuthorization.request()
        guard newStatus == .authorized else {
            await MainActor.run {
                self.status = newStatus
                self.errorMessage = "Apple Music access is required to continue."
                self.isLoading = false
            }
            return
        }

        await MainActor.run { self.status = newStatus }

        do {
            let devToken = try await fetchDeveloperToken()
            let provider = MusicUserTokenProvider()
            let token = try await provider.userToken(for: devToken, options: .init())
            await MainActor.run {
                self.userToken = token
                self.isLoading = false
                onAuthorized(token) // ← add this
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to get user token: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }


    func fetchDeveloperToken() async throws -> String {
        let url = URL(string: "https://getmusictoken-6jveqlm3va-uc.a.run.app")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode([String: String].self, from: data)
        guard let token = response["token"] else {
            throw URLError(.badServerResponse)
        }
        return token
    }
}
