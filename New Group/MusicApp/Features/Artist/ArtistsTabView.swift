//
//  ArtistsTabView.swift
//  Resonate
//
//  Created by Russal Arya on 18/9/2025.
//

import SwiftUI
import MusicKit

struct ArtistsTabView: View {
    let userToken: String
    
    @StateObject private var viewModel = ArtistsViewModel()    
    @State private var selectedArtist: Artist?
    
    var body: some View {
        ScrollView {
            TopSpacer()
            
            InlineSearchBar(searchText: $viewModel.searchText, label: "Search artists")
                .padding(.vertical, 6)
                .padding(.horizontal)
            
            if viewModel.isLoading {
                ClassicLoadingView(text: "Loading your artists")
            } else if viewModel.artists.isEmpty {
                EmptyStateView()
            } else if viewModel.groupedArtists.isEmpty && !viewModel.searchText.isEmpty {
                NoResultsView(searchText: viewModel.searchText)
            } else {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.sortedKeys, id: \.self) { key in
                        ArtistsSection(key: key, artists: viewModel.groupedArtists[key] ?? []) { artist in
                            selectedArtist = artist
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal)
            }
        }
        .onChange(of: viewModel.searchText) { viewModel.applyFilter() }
        .task {
            await viewModel.fetchLibraryArtists()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .navigationDestination(item: $selectedArtist) { artist in
            ArtistView(artist: artist)
            .ignoresSafeArea(edges: .top) // extend under status bar
        }
    }
}
