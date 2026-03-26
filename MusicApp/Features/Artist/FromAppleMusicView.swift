//
//  FromAppleMusicView.swift
//  MusicApp
//
//  Created by Russal Arya on 5/10/2025.
//

import SwiftUI
import MusicKit

struct FromAppleMusicView: View {
    var detailedArtist: Artist?
    var adjustedArtworkColor: Color
    var errorMessage: String?
    
    let setSelectedSong: (Song) -> Void
    let setSelectedAlbum: (Album) -> Void
    
    var body: some View {
        if let detailedArtist = detailedArtist {
            if let latestRelease = detailedArtist.latestRelease {
                VStack {
                    Title(text: "Latest Release")
                        .foregroundColor(adjustedArtworkColor)
                    
                    HStack {
                        LargeMusicItemBlock(
                            artwork: latestRelease.artwork,
                            title: latestRelease.title,
                            artistName: latestRelease.artistName,
                            playCount: nil,
                            size: 160
                        ) {
                            setSelectedAlbum(latestRelease)
                        }
                        Spacer()
                    }
                    
                }
                .padding(.bottom, 2)
            }
            
            
            if let topSongs = detailedArtist.topSongs {
                VStack {
                    Title(text: "Top Songs")
                        .foregroundColor(adjustedArtworkColor)
                    
                    ForEach(topSongs.prefix(5), id: \.id) { song in
                        // VStack {
                        SongRow(
                            song: song,
                            toggleAddPlaylists: {}
                        ) {
                            setSelectedSong(song)
                        }
                        // }
                    }
                }
                .padding(.bottom, 18)
            }
            
            if let albums = detailedArtist.fullAlbums {
                VStack {
                    if albums.first != nil {
                        Title(text: "Albums")
                            .foregroundColor(adjustedArtworkColor)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(albums, id: \.id) { album in
                                    AlbumRow(album: album, size: 140) {
                                        setSelectedAlbum(album)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        } else {
            // Loading state
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5) // make it bigger if you want
                    .padding(.top, 20)
            }
        }
    }
}
