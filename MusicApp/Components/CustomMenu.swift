//
//  CustomMenu.swift
//  Resonate
//
//  Created by Russal Arya on 28/11/2025.
//

import SwiftUI
import MusicKit

struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String?
    let label: String
    let action: () -> Void
    var role: ButtonRole? = nil
}

extension MenuItem: Equatable {
    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        // Compare only stable, hashable properties. Closures are not Equatable.
        return lhs.id == rhs.id && lhs.icon == rhs.icon && lhs.label == rhs.label
    }
}

extension MenuItem: Hashable {
    func hash(into hasher: inout Hasher) {
        // Hash only stable, hashable properties. Do not include the closure.
        hasher.combine(id)
        hasher.combine(icon)
        hasher.combine(label)
    }
}

func generateMenu(_ menuItems: [[MenuItem]]) -> some View {
    ForEach(menuItems.indices, id: \.self) { sectionIndex in
        let section = menuItems[sectionIndex]
        ForEach(section.indices, id: \.self) { itemIndex in
            let menuItem = section[itemIndex]
            MenuRow(menuItem: menuItem)
        }
        if sectionIndex < menuItems.count - 1 {
            Divider()
        }
    }
}

struct MenuRow: View {
    let menuItem: MenuItem
    var color: Color = .resonatePurple

    private var accentColor: Color {
        menuItem.role == .destructive ? .red : color
    }

    var body: some View {
        Button(action: menuItem.action) {
            HStack(spacing: 8) {
                if let icon = menuItem.icon {
                    Image(systemName: icon)
                        .font(.montserrat(size: 16, weight: .bold))
                        .foregroundColor(accentColor)
                        .frame(width: 36, height: 36)
//                        .background(accentColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                Text(menuItem.label)
                    .font(.montserrat(size: 16, weight: .bold))
                    .tracking(16 * -0.025)
                    .foregroundStyle(menuItem.role == .destructive ? Color.red : accentColor)

                Spacer()

//                Image(systemName: "chevron.right")
//                    .font(.system(size: 12, weight: .semibold))
//                    .foregroundColor(Color.secondary.opacity(0.4))
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

func getMenuForSong(
    _ song: SongOrTrack,
    showMessage: @escaping (String) async -> Void,
    showError: @escaping (String) async -> Void,
    toggleAddPlaylists: @escaping () -> Void,
    goToAlbum: @escaping () -> Void,
    goToArtist: @escaping () -> Void
) -> [[MenuItem]] {
    
    return [
        [
//            MenuItem(
//                icon: "square.and.arrow.up",
//                label: "Share",
//                action: {}
//            ),
            MenuItem(
                icon: "text.badge.plus",
                label: "Add to Playlist",
                action: { toggleAddPlaylists() }
//            ),
//            MenuItem(
//                icon: "chart.xyaxis.line",
//                label: "View Stats",
//                action: {}
            )
        ],
        [
            MenuItem(
                icon: "square.stack",
                label: "Go to Album",
                action: { goToAlbum() }
            ),
            MenuItem(
                icon: "person.fill",
                label: "Go to Artist",
                action: { goToArtist() }
            )
        ],
        [
            MenuItem(
                icon: "text.line.first.and.arrowtriangle.forward",
                label: "Play Next",
                action: {
                    addToPlayNext(
                        song,
                        showMessage: showMessage,
                        showError: showError
                    )
                }
            ),
            MenuItem(
                icon: "text.line.last.and.arrowtriangle.forward",
                label: "Add to Queue",
                action: {
                    addToQueue(
                        song,
                        showMessage: showMessage,
                        showError: showError
                    )
                }
            )
        ],
//        [
//            MenuItem(
//                icon: "trash.fill",
//                label: "Delete from Library",
//                action: {},
//                role: .destructive
//            )
//        ]
    ]
}

func getMenuForAlbum(
    _ album: Album,
    showMessage: @escaping (String) async -> Void,
    showError: @escaping (String) async -> Void,
    toggleAddPlaylists: @escaping () -> Void
) -> [[MenuItem]] {
    return [
//        [
//            MenuItem(
//                icon: "square.and.arrow.up",
//                label: "Share",
//                action: {}
//            ),
//            // need to add for album
//            MenuItem(
//                icon: "text.badge.plus",
//                label: "Add to Playlist",
//                action: { toggleAddPlaylists() }
//            ),
//            MenuItem(
//                icon: "chart.xyaxis.line",
//                label: "View Stats",
//                action: {}
//            )
//        ],
//        // to add
//        [
//            MenuItem(
//                icon: "person.fill",
//                label: "Go to Artist",
//                action: {}
//            )
//        ],
        [
            MenuItem(
                icon: "text.line.first.and.arrowtriangle.forward",
                label: "Play Next",
                action: {
                    addAlbumToPlayNext(
                        album,
                        showMessage: showMessage,
                        showError: showError
                    )
                }
            ),
            MenuItem(
                icon: "text.line.last.and.arrowtriangle.forward",
                label: "Add to Queue",
                action: {
                    addAlbumToQueue(
                        album,
                        showMessage: showMessage,
                        showError: showError
                    )
                }
            )
        ],
//        [
//            MenuItem(
//                icon: "trash.fill",
//                label: "Delete from Library",
//                action: {},
//                role: .destructive
//            )
//        ]
    ]
}

func getMenuForPlaylist(
    _ playlist: Playlist,
    showMessage: @escaping (String) async -> Void,
    showError: @escaping (String) async -> Void,
    toggleAddPlaylists: @escaping () -> Void
) -> [[MenuItem]] {
    return [
//        [
//            MenuItem(
//                icon: "square.and.arrow.up",
//                label: "Share",
//                action: {}
//            ),
//            MenuItem(
//                icon: "text.badge.plus",
//                label: "Add to Playlist",
//                action: { toggleAddPlaylists() }
//            ),
//            // view stats may be redundant
//            MenuItem(
//                icon: "chart.xyaxis.line",
//                label: "View Stats",
//                action: {}
//            )
//        ],
        [
            MenuItem(
                icon: "text.line.first.and.arrowtriangle.forward",
                label: "Play Next",
                action: {
                    addPlaylistToPlayNext(
                        playlist,
                        showMessage: showMessage,
                        showError: showError
                    )
                }
            ),
            MenuItem(
                icon: "text.line.last.and.arrowtriangle.forward",
                label: "Add to Queue",
                action: {
                    addPlaylistToQueue(
                        playlist,
                        showMessage: showMessage,
                        showError: showError
                    )
                }
            )
        ],
//        [
//            MenuItem(
//                icon: "trash.fill",
//                label: "Delete from Library",
//                action: {},
//                role: .destructive
//            )
//        ]
    ]
}

struct CustomMenu: View {
    let artwork: Artwork?
    let title: String
    let subtitle: String?
    let color: Color
    let menuItems: [[MenuItem]]
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var betterTextColor: Color {
        // depend on colorScheme to force recalculation on toggle
        _ = colorScheme
        
        // Safely unwrap MusicKit-provided CGColors and construct UIColors correctly.
        // Fallback to .resonatePurple if anything is missing.
        guard
            let textCG = artwork?.primaryTextColor,
            let bgCG = artwork?.backgroundColor
        else {
            return .resonatePurple
        }

        let textColor = UIColor(cgColor: textCG)
        let bgColor = UIColor(cgColor: bgCG)
        return idealColor(textColor: textColor, backgroundColor: bgColor)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Horizontal header
            HStack(spacing: 14) {
                ArtworkView(
                    artwork: artwork,
                    width: 52,
                    height: 52,
                    cornerRadius: 10
                )
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.montserrat(size: 16, weight: .bold))
                        .tracking(16 * -0.025)
                        .foregroundStyle(betterTextColor)
                        .lineLimit(1)

                    if let subtitle {
                        Text(subtitle)
                            .font(.montserrat(size: 15, weight: .medium))
                            .tracking(15 * -0.025)
                            .foregroundStyle(betterTextColor.opacity(0.8))
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider()

            // Menu sections
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(menuItems.indices, id: \.self) { sectionIndex in
                        let section = menuItems[sectionIndex]
                        VStack(spacing: 0) {
                            ForEach(section.indices, id: \.self) { itemIndex in
                                MenuRow(
                                    menuItem: section[itemIndex],
                                    color: betterTextColor
                                )
                                if itemIndex < section.count - 1 {
                                    Divider()
                                        .padding(.leading, 56)
                                }
                            }
                        }
                        .background(Color.resonatePurple.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.resonatePurple.opacity(0.12), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
    }
}

