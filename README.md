# TrackSense
An open source Apple Music Companion app designed to provide users with deep insights into their music listening habits.
The app leverages Apple's MusicKit framework to access library data and Firebase to persist analytics and trends in a cloud-synced environment.

## Features
*   **Comprehensive Music Stats:** Get deep insights into your listening habits. View your top songs, albums, and artists, sortable by either play count or total listening time.
*   **Historical Trends:** Visualize your listening history with detailed charts. See how plays for your favorite items and overall library stats evolve over time. Includes trend analysis for daily growth, weekly momentum, and listening streaks.
*   **Cloud Sync:** Anonymously syncs your listening data to a personal Firebase backend to track long-term trends, play history, and milestones.
*   **Dynamic "Now Playing" UI:** A beautiful, expandable player that adapts its color scheme to the current song's artwork. Features full playback controls, repeat/shuffle modes, progress scrubbing, and AirPlay integration.
*   **Full Library Browsing:** Explore your entire Apple Music library including songs, albums, artists, and playlists through a clean and intuitive interface.
*   **Playlist Management:** Seamlessly add tracks to your existing playlists or create new ones from within the app.
*   **Detailed Views:** Dive deep into individual song, album, and artist pages, complete with tracklists, stats, and metadata.

## Core Functionality
- **Music Insights:** Visualizes listening statistics such as total play hours, top artists, and weekly trends.
- **Library Management:** Provides an enhanced interface for browsing songs, albums, and playlists.
- **Cloud Sync:** Uses anonymous authentication to sync user statistics across devices without requiring a traditional account.
- **Enhanced Playback:** Includes a custom "Now Playing" experience with integrated stats and queue management

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
│   ├── Charts/                 History and playcount chart views
│   ├── Controls/               Menus, pickers, and search inputs
│   ├── Layout/                 Layout utilities and general UI primitives
│   ├── MusicItem/              Artwork, item blocks, and detail views
│   └── Playback/               AirPlay picker and output button
└── Managers/                   App-wide state and service managers
    ├── AuthManager.swift
    ├── OverlayManager.swift
    ├── SessionManager.swift
    └── SongLibraryManager.swift
```

## License
This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for more details.