//
//  AuthManager.swift
//  Resonate
//
//  Created by Russal Arya on 10/11/2025.
//


import FirebaseAuth
import SwiftUI
internal import Combine

@MainActor
final class AuthManager: ObservableObject {
    @AppStorage("firebaseUID") private var firebaseUID: String = ""
    @Published var userID: String?

    init() {
        userID = Auth.auth().currentUser?.uid ?? firebaseUID
        Task {
            await signInIfNeeded()
        }
    }

    func signInIfNeeded() async {
        // Already signed in?
        if let currentUser = Auth.auth().currentUser {
            userID = currentUser.uid
            firebaseUID = currentUser.uid
            return
        }

        do {
            let result = try await Auth.auth().signInAnonymously()
            userID = result.user.uid
            firebaseUID = result.user.uid
            print("Signed in anonymously with UID:", result.user.uid)
        } catch {
            print("Auth error:", error.localizedDescription)
        }
    }
}
