//
//  SessionManager.swift
//  TrackSense
//
//  Created by Russal Arya on 15/4/2026.
//

import SwiftUI
import MusicKit
internal import Combine

@MainActor
final class SessionManager: ObservableObject {
    @Published var isSessionActive: Bool = false
    @Published var sessionQueue: [Song] = []
    @Published var sessionStartTime: Date?

    func startSession(currentSong: Song?) {
        sessionQueue = currentSong.map { [$0] } ?? []
        sessionStartTime = Date()
        isSessionActive = true
    }

    func endSession() {
        isSessionActive = false
        sessionQueue = []
        sessionStartTime = nil
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        sessionQueue.move(fromOffsets: source, toOffset: destination)
    }

    func removeItem(at offsets: IndexSet) {
        sessionQueue.remove(atOffsets: offsets)
    }
}
