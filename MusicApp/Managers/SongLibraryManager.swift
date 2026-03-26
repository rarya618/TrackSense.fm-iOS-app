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
    @Published var errorMessage: String?
    
    private var hasFetched = false

    func fetchSongsIfNeeded() async {
        guard !hasFetched, !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await MusicLibraryRequest<Song>().response()
            songs = Array(response.items)
            hasFetched = true
        } catch {
            errorMessage = "Failed to fetch songs from library."
        }

        isLoading = false
    }
}
