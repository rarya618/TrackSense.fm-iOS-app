//
//  ArtistsViewModel.swift
//  Resonate
//
//  Created by Russal Arya on 8/10/2025.
//

import SwiftUI
import MusicKit
internal import Combine

@MainActor
final class ArtistsViewModel: ObservableObject {
    @Published var artists: MusicItemCollection<Artist> = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var searchText = ""

    @Published private(set) var groupedArtists: [String: [Artist]] = [:]
    @Published private(set) var sortedKeys: [String] = []

    func fetchLibraryArtists() async {
        isLoading = true
        do {
            let status = await MusicAuthorization.request()
            guard status == .authorized else {
                errorMessage = "Music library access is required."
                isLoading = false
                return
            }
            let request = MusicLibraryRequest<Artist>()
            let response = try await request.response()
            artists = response.items
            applyFilter()
        } catch {
            errorMessage = "Failed to fetch artists: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func applyFilter() {
        let filtered = searchText.isEmpty
            ? Array(artists)
            : artists.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
              }

        let grouped = Dictionary(grouping: filtered) { artist in
            guard let firstChar = artist.name.first else { return "#" }
            let char = String(firstChar).uppercased()
            return char.rangeOfCharacter(from: .letters) != nil ? char : "#"
        }

        groupedArtists = grouped
        sortedKeys = grouped.keys.sorted {
            if $0 == "#" { return false }
            if $1 == "#" { return true }
            return $0 < $1
        }
    }
}
