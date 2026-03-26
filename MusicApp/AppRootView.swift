import SwiftUI
import MusicKit

struct AppRootView: View {
    @AppStorage("isAuthorized") private var isAuthorized: Bool = false
    @State private var userToken: String?
    @State private var isLoading: Bool = true
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else if isAuthorized, let token = userToken {
                MainAppView(userToken: token)
            } else {
                AuthView(onAuthorized: { token in
                    self.userToken = token
                    self.isAuthorized = true
                })
            }
        }
        .task {
            await checkAuthorization()
        }
    }
    
    private func checkAuthorization() async {
        // Simulate small delay for splash feel
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let status = await MusicAuthorization.currentStatus
        if status == .authorized {
            // You can load stored token from Keychain here
            userToken = UserDefaults.standard.string(forKey: "userToken")
            isAuthorized = userToken != nil
        }
        await MainActor.run { isLoading = false }
    }
}
