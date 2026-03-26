//
//  AlbumsViewModel.swift
//  MusicApp
//
//  Created by Russal Arya on 6/10/2025.
//

import SwiftUI
import MusicKit
internal import Combine

@MainActor
final class AlbumsViewModel: ObservableObject {
    @Published var albums: MusicItemCollection<Album> = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var searchText = ""

    @Published private(set) var groupedAlbums: [String: [Album]] = [:]
    @Published private(set) var sortedKeys: [String] = []

    func fetchLibraryAlbums() async {
        isLoading = true
        do {
            let status = await MusicAuthorization.request()
            guard status == .authorized else {
                errorMessage = "Music library access is required."
                isLoading = false
                return
            }
            let request = MusicLibraryRequest<Album>()
            let response = try await request.response()
            albums = response.items
            applyFilter()
        } catch {
            errorMessage = "Failed to fetch albums: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func applyFilter() {
        let filtered = searchText.isEmpty
            ? Array(albums)
            : albums.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.artistName.localizedCaseInsensitiveContains(searchText)
              }

        let grouped = Dictionary(grouping: filtered) { album in
            guard let firstChar = album.title.first else { return "#" }
            let char = String(firstChar).uppercased()
            return char.rangeOfCharacter(from: .letters) != nil ? char : "#"
        }

        groupedAlbums = grouped
        sortedKeys = grouped.keys.sorted {
            if $0 == "#" { return false }
            if $1 == "#" { return true }
            return $0 < $1
        }
    }
}
