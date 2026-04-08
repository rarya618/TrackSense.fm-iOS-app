//
//  SongLibraryManager.swift
//  Resonate
//
//  Created by Russal Arya on 17/12/2025.
//

import SwiftUI
import MusicKit
internal import Combine

@MainActor
final class SongLibraryManager: ObservableObject {
    @Published var songs: [Song] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    
    private var hasFetched = false
    
    private func fetchSongs() async throws {
        let response = try await MusicLibraryRequest<Song>().response()
        songs = Array(response.items)
    }

    func fetchSongsIfNeeded() async {
        guard !hasFetched, !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await fetchSongs()
            hasFetched = true
        } catch {
            errorMessage = "Failed to fetch songs from library."
        }
    }

    func refreshLibrary() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        errorMessage = nil
        defer { isRefreshing = false }

        do {
            try await fetchSongs()
            hasFetched = true
        } catch {
            errorMessage = "Failed to refresh library."
        }
    }
}
