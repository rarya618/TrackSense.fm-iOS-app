//
//  SongLyricsView.swift
//  TrackSense
//
//  Created by Russal Arya on 16/4/2026.
//

import SwiftUI
import MusicKit

// MARK: - View

struct SongLyricsView: View {
    let song: any SongOrTrack
    var color: Color = .resonatePurple

    @State private var lyrics: String = ""
    @State private var instrumental = false
    @State private var isLoading = true
    @State private var failed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "Lyrics",
                subtitle: "Powered by LRCLIB",
                hasLeadingPadding: false
            )

            if isLoading {
                HStack {
                    Spacer()
                    ProgressView().tint(color)
                    Spacer()
                }
                .padding(.vertical, 40)

            } else if failed || lyrics.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: instrumental ? "pianokeys" : "text.quote")
                        .font(.system(size: 34))
                        .foregroundStyle(color.opacity(0.35))

                    Text(failed ? "Couldn't load lyrics" : instrumental ? "Instrumental" : "No lyrics found")
                        .font(.montserrat(size: 20, weight: .bold))
                        .tracking(20 * -0.025)
                        .foregroundStyle(.primary)

                    Text(failed
                         ? "Something went wrong. Try again later."
                         : instrumental
                            ? "This track has no lyrics."
                            : "LRCLIB doesn't have lyrics for this track.")
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
                Text(lyrics)
                    .font(.montserrat(size: 20, weight: .bold))
                    .tracking(20 * -0.025)
                    .lineSpacing(7)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 24)
            }
        }
        .task { await loadLyrics() }
    }

    private func loadLyrics() async {
        isLoading = true
        failed = false
        instrumental = false

        do {
            let result = try await fetchLRCLIBLyrics(
                title: song.title,
                artist: song.artistName,
                album: song.albumTitle
            )
            instrumental = result.instrumental
            lyrics = result.plainLyrics ?? ""
        } catch {
            failed = true
        }

        isLoading = false
    }
}

// MARK: - LRCLIB response model

private struct LRCLIBResponse: Decodable {
    let instrumental: Bool
    let plainLyrics: String?
}

// MARK: - Fetch

private func fetchLRCLIBLyrics(title: String, artist: String, album: String?) async throws -> LRCLIBResponse {
    var components = URLComponents(string: "https://lrclib.net/api/get")!
    components.queryItems = [
        URLQueryItem(name: "track_name", value: title),
        URLQueryItem(name: "artist_name", value: artist),
    ]
    if let album {
        components.queryItems?.append(URLQueryItem(name: "album_name", value: album))
    }

    guard let url = components.url else { throw URLError(.badURL) }
    let (data, response) = try await URLSession.shared.data(from: url)

    if let http = response as? HTTPURLResponse, http.statusCode == 404 {
        return LRCLIBResponse(instrumental: false, plainLyrics: nil)
    }

    return try JSONDecoder().decode(LRCLIBResponse.self, from: data)
}
