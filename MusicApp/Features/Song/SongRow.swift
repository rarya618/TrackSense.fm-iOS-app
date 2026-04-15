//
//  SongRow.swift
//  Resonate
//
//  Created by Russal Arya on 21/9/2025.
//

import SwiftUI
import MusicKit

struct SongRow: View {
    let song: Song
    let toggleAddPlaylists: () -> Void
    let onTap: () -> Void
    
    @EnvironmentObject var overlayManager: OverlayManager

    var body: some View {
        MusicItemBlock(
            artwork: song.artwork,
            title: song.title,
            artistName: song.artistName,
            playCount: song.playCount,
            removeSpacer: false,
            removeEllipsis: true, // removed temporaily until feature is added
//            menuItems: getMenuForSong(
//                song,
//                showMessage: { msg in await showMessage(msg) },
//                showError: { msg in await showError(msg) },
//                toggleAddPlaylists: toggleAddPlaylists
//            )
        ) {
            onTap()
        }
    }
    
    // MARK: - Show Overlays
    func showMessage(_ message: String) async {
        await displayMessage(message) { msg in
            overlayManager.showOverlay(msg)
        }
    }

    func showError(_ message: String) async {
        await displayMessage(message) { msg in
            overlayManager.showError(msg)
        }
    }
}
