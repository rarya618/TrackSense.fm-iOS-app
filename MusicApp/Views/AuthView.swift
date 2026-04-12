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
    @EnvironmentObject var overlayManager: OverlayManager
    
    @State private var status: MusicAuthorization.Status = .notDetermined
    @State private var isLoading = false
    @State private var userToken: String?
    
    // States for permissions required
    @State private var isAppleMusicAuthorised = false
    @State private var isCloudSyncAuthorised = false
    
    @State private var buttonPressed = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text("Permissions")
                        .font(.montserrat(size: 32, weight: .bold))
                        .lineSpacing(8)
                        .foregroundColor(.primary)
                    
                    // Body paragraphs
                    Group {
                        Text("Hi!")
                        
                        Text("I am glad to have you here.")
                        
                        Text({
                            var s = AttributedString("To get your personal insights ready, I need your help with two things:")
                            if let range = s.range(of: "two") {
                                s[range].inlinePresentationIntent = .stronglyEmphasized
                            }
                            return s
                        }())
                        .foregroundColor(.primary)
                    }
                    .font(.montserrat(size: 17))
                    .lineSpacing(8)
                    .foregroundColor(.primary)
                    
                    // Permission cards
                    PermissionCard(
                        icon: "music.note",
                        title: "Access to Apple Music",
                        description: "I'll use this to pull in your listening history.",
                        buttonText: "Authorise",
                        isAuthorised: isAppleMusicAuthorised,
                        buttonAction: {
                            Task {
                                let success = await requestAuthorizationForAppleMusic()
                                
                                await MainActor.run {
                                    isAppleMusicAuthorised = success
                                }
                            }
                        }
                    )
                    
                    PermissionCard(
                        icon: "cloud.fill",
                        title: "Sync with cloud",
                        description: "Your data is fully anonymised, and no identifying personal info is stored.",
                        buttonText: "I agree",
                        isAuthorised: isCloudSyncAuthorised,
                        buttonAction: {
                            isCloudSyncAuthorised = true
                        }
                    )
                    
                    // Footer paragraphs
                    Group {
                        Text("You need an active Apple Music subscription to make the magic happen.")
                        
                        Text("If you're not down for these, no hard feelings! But I won't be able to show you your insights without them.")
                    }
                    .font(.montserrat(size: 17))
                    .lineSpacing(8)
                    .foregroundColor(.primary)
                    
                    Group {
                        Text("Ready to vibe?")
                            .padding(.top, 12)
                        
                        Text("– Russ")
                    }
                    .font(.montserrat(size: 17))
                    .lineSpacing(8)
                    .foregroundColor(.primary)
                }
                .padding(.horizontal)
                .padding(.top, 70)
                .padding(.bottom, 120)
            }
            .ignoresSafeArea()
            
            if buttonPressed {
                ProgressView()
            } else {
                StandardButton(
                    label: "Continue",
                    isDisabled: !(isAppleMusicAuthorised && isCloudSyncAuthorised),
                    action: {
                        Task {
                            await MainActor.run {
                                buttonPressed = true
                            }
                            
                            await authorizeAndFetchToken()
                        }
                    }
                )
                .padding(.horizontal)
            }
        }
    }
    
    // Request Apple Music authorization
    func requestAuthorizationForAppleMusic() async -> Bool {
        await MainActor.run { self.isLoading = true }
        await MainActor.run { overlayManager.showError(nil) }
        
        let newStatus = await MusicAuthorization.request()
        guard newStatus == .authorized else {
            await MainActor.run {
                self.status = newStatus
                self.isLoading = false
            }
            await showError("Access to Apple Music is required to continue.")
            
            return false
        }
        
        await MainActor.run { self.status = newStatus }
        
        // Use subscriptionUpdates to get a reliable first value
        // .current can return a stale/incorrect snapshot on first call
        do {
            let canPlay = try await withThrowingTaskGroup(of: Bool.self) { group in
                // Primary: wait for first value from the subscription stream
                group.addTask {
                    for await subscription in MusicSubscription.subscriptionUpdates {
                        return subscription.canPlayCatalogContent
                    }
                    return false
                }
                
                // Fallback timeout after 5 seconds
                group.addTask {
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                    throw CancellationError()
                }
                
                // Return whichever finishes first (the stream value or timeout)
                defer { group.cancelAll() }
                if let result = try await group.next() {
                    return result
                }
                return false
            }
            
            guard canPlay else {
                await MainActor.run { self.isLoading = false }
                await showError("An active Apple Music subscription is required to use this app.")
                return false
            }
            
        } catch {
            // Timeout or cancellation — fall back to .current as last resort
            let fallback = try? await MusicSubscription.current
            guard fallback?.canPlayCatalogContent == true else {
                await MainActor.run { self.isLoading = false }
                await showError("Could not verify your Apple Music subscription. Please try again.")
                return false
            }
        }
        
        await MainActor.run { self.isLoading = false }
        return true
    }

    // Handle full flow
    func authorizeAndFetchToken() async {
        await MainActor.run { self.isLoading = true }
        await MainActor.run { overlayManager.showError(nil) }

        do {
            let devToken = try await fetchDeveloperToken()
            print("Dev token received: \(devToken.prefix(20))...") // Don't log full token
            let provider = MusicUserTokenProvider()
            let token = try await provider.userToken(for: devToken, options: .init())
            await MainActor.run {
                self.userToken = token
                self.isLoading = false
                onAuthorized(token) // ← add this
            }
        } catch let error as MusicTokenRequestError {
            switch error {
            case .privacyAcknowledgementRequired:
                // Open Apple Music so user can accept privacy terms
                await MainActor.run {
                    self.isLoading = false
                    buttonPressed = false
                }
                await showError("Please open the Music app, accept the terms, then try again.")
            default:
                await MainActor.run {
                    self.isLoading = false
                    buttonPressed = false
                }
                await showError("Failed to request music token: \(error.localizedDescription)")
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                buttonPressed = false
            }
            await showError("Failed to request user token: \(error.localizedDescription)")
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
    
    func showError(_ message: String) async {
        await displayMessage(message) { msg in
            overlayManager.showError(msg)
        }
    }
}

