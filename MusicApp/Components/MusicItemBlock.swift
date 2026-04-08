//
//  MusicItemBlock.swift
//  Resonate
//
//  Created by Russal Arya on 24/9/2025.
//

import SwiftUI
import MusicKit

struct MusicItemBlock: View {
    let artwork: Artwork?
    let title: String
    let artistName: String?
    let playCount: Int?
    let removeSpacer: Bool?
    let removeEllipsis: Bool?
    var primaryColor: Color = .resonatePurple
    var secondaryColor: Color = .resonateLightPurple
    var menuItems: [[MenuItem]] = []
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.15)) {
                onTap()
            }
        }, label: {
            HStack(spacing: 14) {
                ArtworkView(
                    artwork: artwork,
                    width: 52,
                    height: 52,
                    cornerRadius: 10
                )
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.montserrat(size: 17, weight: .semibold))
                            .foregroundColor(primaryColor)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            if let artist = artistName {
                                Text(artist)
                                    .font(.montserrat(size: 14))
                                    .foregroundColor(secondaryColor)
                                    .lineLimit(1)
                            }
                            
                            if let plays = playCount {
                                Circle()
                                    .fill(Color.customLightPurple.opacity(0.4))
                                    .frame(width: 3, height: 3)
                                Text(plays.formatted() + " play" + (plays == 1 ? "" : "s"))
                                    .font(.montserrat(size: 14))
                                    .foregroundColor(secondaryColor)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    if removeSpacer == nil {
                        Spacer(minLength: 2)
                    } else if !(removeSpacer ?? false) {
                        Spacer(minLength: 2)
                    }
                
                    if removeEllipsis == nil {
                        Menu {
                            generateMenu(menuItems)
                        } label: {
                            Image(systemName: "ellipsis")
                                .fontWeight(.bold)
                                .font(Font.montserrat(size: 24))
                                .foregroundColor(primaryColor)
                                .frame(width: 44, height: 44)
                                .contentShape(Circle())
                        }
                    } else if !(removeEllipsis ?? false) {
                        Menu {
                            generateMenu(menuItems)
                        } label: {
                            Image(systemName: "ellipsis")
                                .fontWeight(.bold)
                                .font(.montserrat(size: 24))
                                .foregroundColor(primaryColor)
                                .frame(width: 44, height: 44)
                                .contentShape(Circle())
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .contentShape(Rectangle())
        })
        .buttonStyle(.plain) // removes SwiftUI’s default button tint
    }
}
