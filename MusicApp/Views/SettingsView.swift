//
//  SettingsView.swift
//  TrackSense
//
//  Created by Russal Arya on 15/4/2026.
//

import SwiftUI
import MusicKit

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var songLibraryManager: SongLibraryManager

    @AppStorage("lastStatsSync") var lastStatsSync: Date?
    @AppStorage("autoSync") var autoSync: Bool = true

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    private var truncatedUID: String {
        guard let uid = authManager.userID else { return "Not signed in" }
        return String(uid.prefix(8)) + "••••••••"
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: Account
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.resonatePurple)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Anonymous account")
                                .font(.montserrat(size: 15, weight: .bold))
                                .tracking(15 * -0.025)
                            Text(truncatedUID)
                                .font(.montserrat(size: 13, weight: .medium))
                                .tracking(13 * -0.025)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Account")
                        .font(.montserrat(size: 14, weight: .semibold))
                        .tracking(14 * -0.025)
                }

                // MARK: Sync
                Section {
                    Toggle(isOn: $autoSync) {
                        Label {
                            Text("Auto-sync on launch")
                                .font(.montserrat(size: 15, weight: .medium))
                                .tracking(15 * -0.025)
                        } icon: {
                            Image(systemName: "arrow.clockwise.icloud")
                                .foregroundStyle(Color.resonatePurple)
                        }
                    }
                    .tint(.resonatePurple)

                    HStack {
                        Label {
                            Text("Last synced")
                                .font(.montserrat(size: 15, weight: .medium))
                                .tracking(15 * -0.025)
                        } icon: {
                            Image(systemName: "clock")
                                .foregroundStyle(Color.resonatePurple)
                        }
                        Spacer()
                        Text(lastStatsSync?.formatted(date: .abbreviated, time: .shortened) ?? "Never")
                            .font(.montserrat(size: 15, weight: .medium))
                            .tracking(15 * -0.025)
                            .foregroundStyle(Color.secondary)
                    }
                } header: {
                    Text("Sync")
                        .font(.montserrat(size: 14, weight: .semibold))
                        .tracking(14 * -0.025)
                }

                // MARK: Library
                Section {
                    HStack {
                        Label {
                            Text("Songs")
                                .font(.montserrat(size: 15, weight: .medium))
                                .tracking(15 * -0.025)
                        } icon: {
                            Image(systemName: "music.note")
                                .foregroundStyle(Color.resonatePurple)
                        }
                        Spacer()
                        Text(songLibraryManager.songs.count.formatted())
                            .font(.montserrat(size: 15, weight: .semibold))
                            .tracking(15 * -0.025)
                            .foregroundStyle(Color.secondary)
                    }

                    HStack {
                        Label {
                            Text("Library status")
                                .font(.montserrat(size: 15, weight: .medium))
                                .tracking(15 * -0.025)
                        } icon: {
                            Image(systemName: songLibraryManager.isLoading ? "hourglass" : "checkmark.circle")
                                .foregroundStyle(Color.resonatePurple)
                        }
                        Spacer()
                        Text(songLibraryManager.isLoading ? "Loading…" : "Up to date")
                            .font(.montserrat(size: 15, weight: .medium))
                            .tracking(15 * -0.025)
                            .foregroundStyle(Color.secondary)
                    }
                } header: {
                    Text("Library")
                        .font(.montserrat(size: 14, weight: .semibold))
                        .tracking(14 * -0.025)
                }

                // MARK: About
                Section {
                    HStack {
                        Label {
                            Text("Version")
                                .font(.montserrat(size: 15, weight: .medium))
                                .tracking(15 * -0.025)
                        } icon: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(Color.resonatePurple)
                        }
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .font(.montserrat(size: 15, weight: .medium))
                            .tracking(15 * -0.025)
                            .foregroundStyle(Color.secondary)
                    }
                } header: {
                    Text("About")
                        .font(.montserrat(size: 14, weight: .semibold))
                        .tracking(14 * -0.025)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.montserrat(size: 17, weight: .bold))
                        .tracking(17 * -0.025)
                }
            }
        }
    }
}
