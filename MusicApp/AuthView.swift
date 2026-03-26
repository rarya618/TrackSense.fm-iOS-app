import SwiftUI
import MusicKit

struct AuthView: View {
    @State private var status: MusicAuthorization.Status = .notDetermined
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var userToken: String?
    @State private var navigate = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "music.note.list")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.pink)

                Text("Connect to Apple Music")
                    .font(.title)
                    .fontWeight(.bold)

                Text("We’ll use Apple Music to search songs, play your favorites, and personalize your experience. You’ll be asked to allow access on the next screen.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                Spacer()

                if isLoading {
                    ProgressView("Authorizing…")
                } else if status == .authorized, let userToken {
                    Text("✅ Connected")
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                        .onAppear {
                            // Navigate after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                navigate = true
                            }
                        }
                } else {
                    Button(action: {
                        Task {
                            await authorizeAndFetchToken()
                        }
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }

                if let errorMessage {
                    Text("⚠️ \(errorMessage)")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 8)
                }

                Spacer()

                // Hidden NavigationLink triggered programmatically
                NavigationLink(
                    destination: MainAppView(userToken: userToken ?? ""),
                    isActive: $navigate
                ) { EmptyView() }
            }
            .padding()
        }
    }

    // Handle full flow
    func authorizeAndFetchToken() async {
        isLoading = true
        errorMessage = nil

        let newStatus = await MusicAuthorization.request()
        guard newStatus == .authorized else {
            status = newStatus
            errorMessage = "Apple Music access is required to continue."
            isLoading = false
            return
        }

        status = newStatus

        do {
            // 1. Fetch developer token from backend
            let devToken = try await fetchDeveloperToken()
            // 2. Exchange for user token
            let token = try await MusicUserTokenProvider.userToken(for: devToken)
            userToken = token
        } catch {
            errorMessage = "Failed to get user token: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func fetchDeveloperToken() async throws -> String {
        let url = URL(string: "https://your-backend.com/token")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return String(data: data, encoding: .utf8)!
    }
}
