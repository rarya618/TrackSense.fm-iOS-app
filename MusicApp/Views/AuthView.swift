//
//  AuthView.swift
//  Resonate
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
        VStack(spacing: 24) {
            NoteFromMeView()
            
            StandardButton(
                label: "Get started",
                action: {
                    Task {
                        await authorizeAndFetchToken()
                    }
                }
            )
        }
        .padding()
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
            // Create an instance of the provider and pass options as required by the API
            let provider = MusicUserTokenProvider()
            let token = try await provider.userToken(for: devToken, options: .init())
            await MainActor.run {
                self.userToken = token
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to get user token: \(error.localizedDescription)"
            }
        }

        await MainActor.run { self.isLoading = false }
    }


    func fetchDeveloperToken() async throws -> String {
        // ⚠️ ONLY for testing / prototyping
        return "eyJhbGciOiJFUzI1NiIsImtpZCI6IlhQOUg4VDI4NEgiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJXNlk1N0hVNE1RIiwiaWF0IjoxNzU4MDEwMjczLCJleHAiOjE3NzM1NTg2NzN9.BtL-I5JmKHdb7hZmcYSoJwnaxoJ1XtwYOsCggrxVsLSob4IH4F8ilmpXuoBIx9fmndd3kMg2LCS7uyGOowQENQ"
    }
}

