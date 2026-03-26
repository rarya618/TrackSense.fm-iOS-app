import SwiftUI
import MusicKit

struct NowPlayingView: View {
    @State private var currentSong: Song?
    
    var body: some View {
        VStack(spacing: 16) {
            if let song = currentSong {
                Text(song.title)
                    .font(.title2)
                Text(song.artistName)
                    .font(.subheadline)
            } else {
                Text("No song is currently playing")
                    .foregroundColor(.secondary)
            }
        }
        .task {
            await fetchCurrentlyPlaying()
        }
    }
    
    func fetchCurrentlyPlaying() async {
        let player = ApplicationMusicPlayer.shared
        if let entry = player.queue.currentEntry,
           let song = entry.item as? Song {
            await MainActor.run {
                currentSong = song
            }
        }
    }
}