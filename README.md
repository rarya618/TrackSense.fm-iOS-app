# TrackSense

A music analytics companion app for Apple Music. TrackSense connects to your library to surface deep insights into your listening habits — top songs, albums, and artists, historical trends, milestones, and more — synced to a personal cloud backend so your stats persist over time.

---

## Features

- **Stats Dashboard** — View your top songs, albums, and artists sortable by play count or total listening time. Track library-wide metrics like total play hours and play counts with full history.
- **Historical Trends** — Visualize how your listening habits evolve over time with daily and weekly charts. Includes trend analysis for growth, momentum, and streaks.
- **Milestones** — Track how many songs, albums, and artists you've hit at 10, 25, 50, 100, 250, 500, and 1000+ plays.
- **Now Playing** — An immersive full-screen player with dynamic colors from album artwork, playback controls, progress scrubbing, AirPlay integration, and per-song stats.
- **Sessions** — Build and manage custom playback queues with drag-and-drop reordering.
- **Full Library Browsing** — Browse your entire Apple Music library across songs, albums, artists, and playlists.
- **Playlist Management** — Add tracks to existing playlists or create new ones from within the app.
- **Cloud Sync** — Anonymously syncs your stats to a personal Firebase backend. Supports manual sync and optional auto-sync on launch.

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Music | MusicKit, MediaPlayer |
| Backend | Firebase Realtime Database, Firebase Auth (anonymous) |
| Audio | AVFoundation |
| Reactive | Combine |
| Font | Montserrat |

---

## Architecture

The app uses an MVVM-adjacent pattern with environment-injected managers handling shared state:

- **`AuthManager`** — Anonymous Firebase sign-in, maintains user UID across sessions.
- **`SongLibraryManager`** — Fetches and caches the user's Apple Music library.
- **`SessionManager`** — Manages queue-based playback sessions with drag-and-drop support.
- **`OverlayManager`** — Global overlay state for messages and errors.

Sync is unidirectional: local library data is aggregated and pushed to Firebase. Daily history snapshots are stored as `YYYY-MM-DD` keys, enabling chart rendering for any metric over time.

---

## Directory Structure

```
MusicApp/
├── App/                        App entry point and root views
│   ├── ResonateApp.swift
│   ├── AppRootView.swift
│   └── LoadingView.swift
├── Views/                      Top-level navigation destinations
│   ├── HomeView.swift
│   ├── LibraryView.swift
│   ├── StatsView.swift
│   ├── SettingsView.swift
│   └── AuthView.swift
├── Features/                   Self-contained feature modules
│   ├── Album/
│   ├── Artist/
│   ├── NowPlaying/
│   ├── Playlists/
│   ├── Sessions/
│   ├── Song/
│   └── Stats/
├── Components/                 Reusable UI components
│   ├── Charts/                 History and play count chart views
│   ├── Controls/               Menus, pickers, and search inputs
│   ├── Layout/                 Layout utilities and general UI primitives
│   ├── MusicItem/              Artwork, item blocks, and detail views
│   └── Playback/               AirPlay picker and output button
└── Managers/                   App-wide state and service managers
```

---

## Setup

### Requirements

- Xcode 15+
- iOS 16+
- An Apple Music subscription (required for MusicKit library access)
- A Firebase project with Realtime Database enabled

### Firebase

1. Create a Firebase project and enable **Anonymous Authentication** and **Realtime Database**.
2. Download `GoogleService-Info.plist` and place it in `MusicApp/`.
3. The database uses the following structure:

```
users/
  {userID}/
    songs/{songId}/
    albums/{albumId}/
    artists/{artistId}/
    libraryPlayedHours/
    totalPlays/
```

### MusicKit

The app fetches a MusicKit developer token from a remote Cloud Function endpoint. To use your own:

1. Deploy a Cloud Function (or any server) that returns a signed MusicKit developer token as `{ "token": "..." }`.
2. Replace `YOUR_MUSICKIT_TOKEN_ENDPOINT` in `AuthView.swift` with your endpoint URL.

Refer to [Apple's MusicKit documentation](https://developer.apple.com/documentation/musickit) for instructions on generating developer tokens.

---

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for more details.
