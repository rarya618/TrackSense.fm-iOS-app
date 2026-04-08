//
// AlbumsTabView.swift
// Resonate
//
// Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct AlbumsTabView: View {
    let userToken: String

    @StateObject private var viewModel = AlbumsViewModel()
    @State private var selectedAlbum: Album?

    var body: some View {
        ScrollView {
            TopSpacer()
            InlineSearchBar(searchText: $viewModel.searchText, label: "Search albums")
                .padding(.vertical, 6)
                .padding(.horizontal)
            
            if viewModel.isLoading {
                ClassicLoadingView(text: "Loading your albums")
            } else if viewModel.albums.isEmpty {
                EmptyStateView()
            } else if viewModel.groupedAlbums.isEmpty && !viewModel.searchText.isEmpty {
                NoResultsView(searchText: viewModel.searchText)
            } else {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.sortedKeys, id: \.self) { key in
                        AlbumSection(key: key, albums: viewModel.groupedAlbums[key] ?? []) { album in
                            selectedAlbum = album
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .onChange(of: viewModel.searchText) { viewModel.applyFilter() }
        .task {
            await viewModel.fetchLibraryAlbums()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .navigationDestination(item: $selectedAlbum) { album in
            AlbumView(album: album)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "music.note.list")
                .font(.montserrat(size: 60))
                .foregroundColor(.secondary)
            Text("No Albums Found")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Your library albums will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}


struct NoResultsView: View {
    var searchText: String

    var body: some View {
        // No search results
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.montserrat(size: 60))
                .foregroundColor(.secondary)
            Text("No Results for '\(searchText)'")
                .font(.montserrat(size: 36))
                .fontWeight(.semibold)
            Text("Check the spelling or try a new search.")
                .font(.montserrat(size: 20))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
