//
//  SongCreditsView.swift
//  Resonate
//
//  Created by Russal Arya on 16/4/2026.
//

import SwiftUI
import MusicKit

// MARK: - Data Models

struct CreditEntry: Identifiable {
    let id = UUID()
    let label: String
    let artists: [String]
}

// MARK: - Response models

private struct CreditsResponse: Decodable {
    let writerArtists: [SimpleArtist]
    let producerArtists: [SimpleArtist]
    let featuredArtists: [SimpleArtist]
    let customPerformances: [Performance]

    enum CodingKeys: String, CodingKey {
        case writerArtists      = "writer_artists"
        case producerArtists    = "producer_artists"
        case featuredArtists    = "featured_artists"
        case customPerformances = "custom_performances"
    }
}

private struct SimpleArtist: Decodable {
    let name: String
}

private struct Performance: Decodable {
    let label: String
    let artists: [SimpleArtist]
}

// MARK: - View

struct SongCreditsView: View {
    let song: any SongOrTrack
    var color: Color = .resonatePurple

    @State private var credits: [CreditEntry] = []
    @State private var isLoading = true
    @State private var failed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "Credits",
                subtitle: "Artists and contributors",
                hasLeadingPadding: false
            )

            if isLoading {
                HStack {
                    Spacer()
                    ProgressView().tint(color)
                    Spacer()
                }
                .padding(.vertical, 40)

            } else if failed || credits.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "person.slash")
                        .font(.system(size: 34))
                        .foregroundStyle(color.opacity(0.35))

                    Text(failed ? "Couldn't load credits" : "No credits found")
                        .font(.montserrat(size: 20, weight: .bold))
                        .tracking(20 * -0.025)
                        .foregroundStyle(.primary)

                    Text(failed
                         ? "Something went wrong. Try again later."
                         : "No credits are available for this track.")
                        .font(.montserrat(size: 14))
                        .tracking(14 * -0.025)
                        .lineSpacing(4)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)

            } else {
                VStack(spacing: 8) {
                    ForEach(credits) { credit in
                        CreditSection(credit: credit, color: color)
                    }
                }
            }
        }
        .task { await loadCredits() }
    }

    private func loadCredits() async {
        isLoading = true
        failed = false

        do {
            credits = try await fetchCredits(title: song.title, artist: song.artistName)
        } catch {
            failed = true
        }

        isLoading = false
    }
}

// MARK: - Credit Section (collapsible)

private struct CreditSection: View {
    let credit: CreditEntry
    let color: Color

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Text(credit.label)
                        .font(.montserrat(size: 17, weight: .bold))
                        .tracking(17 * -0.025)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(credit.artists.count)")
                        .font(.montserrat(size: 14, weight: .medium))
                        .tracking(14 * -0.025)
                        .foregroundStyle(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(color.opacity(0.12))
                        .clipShape(Capsule())

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 0) {
                    Divider().padding(.horizontal, 16)

                    ForEach(credit.artists, id: \.self) { artist in
                        HStack {
                            Text(artist)
                                .font(.montserrat(size: 16))
                                .tracking(16 * -0.025)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 14)

                        if artist != credit.artists.last {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2))
        )
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
    }
}

// MARK: - Fetch

private func fetchCredits(title: String, artist: String) async throws -> [CreditEntry] {
    var components = URLComponents(string: "https://getcredits-6jveqlm3va-uc.a.run.app")!
    components.queryItems = [
        URLQueryItem(name: "title", value: title),
        URLQueryItem(name: "artist", value: artist)
    ]

    guard let url = components.url else { throw URLError(.badURL) }
    let (data, response) = try await URLSession.shared.data(from: url)

    if let http = response as? HTTPURLResponse, http.statusCode == 404 {
        return []
    }

    let decoded = try JSONDecoder().decode(CreditsResponse.self, from: data)

    // Named groups first, then custom_performances
    let entries: [CreditEntry] = [
        CreditEntry(label: "Writers",          artists: decoded.writerArtists.map(\.name)),
        CreditEntry(label: "Producers",        artists: decoded.producerArtists.map(\.name)),
        CreditEntry(label: "Featured Artists", artists: decoded.featuredArtists.map(\.name)),
    ].filter { !$0.artists.isEmpty }

    let custom = decoded.customPerformances
        .filter { !$0.artists.isEmpty }
        .map { CreditEntry(label: $0.label, artists: $0.artists.map(\.name)) }

    return entries + custom
}
