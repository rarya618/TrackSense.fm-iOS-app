//
//  OverlayManager.swift
//  MusicApp
//
//  Created by Russal Arya on 19/11/2025.
//

import SwiftUI
internal import Combine

final class OverlayManager: ObservableObject {
    @Published var overlayMessage: String?
    @Published var errorMessage: String?

    func showOverlay(_ message: String?) {
        overlayMessage = message
    }

    func showError(_ message: String?) {
        errorMessage = message
    }
}
