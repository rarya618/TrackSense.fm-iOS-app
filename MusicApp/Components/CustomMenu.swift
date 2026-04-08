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

    var body: some View {
        Button(action: menuItem.action) {
            HStack(spacing: 12) {
                if let icon = menuItem.icon {
                    Image(systemName: icon)
                    .fontWeight(.medium)
                    .font(Font.montserrat(size: 20))
                    .frame(width: 32)
                }
                
                Text(menuItem.label)
                Spacer()
            }
        }
        .foregroundStyle(menuItem.role == .destructive ? Color.red : Color.customDark)
        .font(.montserrat(size: 16, weight: .semibold))
        .padding(.vertical, 10)
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
    
    private var betterTextColor: Color {
        let bgCG = Color.resonateWhite
        
        if let textCG = artwork?.backgroundColor {
                let textColor = UIColor(cgColor: textCG)
            let bgColor = UIColor(bgCG)
                return idealColor(textColor: textColor, backgroundColor: bgColor)
        }
        return .resonatePurple
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ArtworkView(
                    artwork: artwork,
                    width: 48,
                    height: 48,
                    cornerRadius: 12
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.montserrat(size: 16, weight: .bold))
                        .lineLimit(1)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.montserrat(size: 15))
                            .lineLimit(1)
                    }
                }
                .foregroundStyle(betterTextColor)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(betterTextColor.opacity(0.04))
                    .stroke(betterTextColor.opacity(0.32), lineWidth: 1)
            )
//            .padding(.horizontal, 12)
//            .padding(.vertical, 12)
//            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))
            
            VStack(spacing: 6) {
                ForEach(menuItems.indices, id: \.self) { sectionIndex in
                    Divider()
                    
                    let section = menuItems[sectionIndex]
                    VStack(spacing: 3) {
                        ForEach(section.indices, id: \.self) { itemIndex in
                            let menuItem = section[itemIndex]
                            MenuRow(menuItem: menuItem)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.resonatePurple.opacity(0.32), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 25)
        
        Spacer()
    }
}
