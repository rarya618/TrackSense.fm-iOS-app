struct LibraryStats: View {
    var songs: [Song]
    var albumStats: [AlbumStat]
    var artistStats: [ArtistStat]
    var playlists: MusicItemCollection<Playlist>

    @State private var songsMilestoneData: [Int: Int] = [:]
    @State private var albumsMilestoneData: [Int: Int] = [:]
    @State private var artistsMilestoneData: [Int: Int] = [:]
    
    @State private var selectedMilestonePage: Int = 0

    var body: some View {
        if songs.isEmpty {
            ClassicLoadingView(text: "Loading data")
        } else {
            VStack (spacing: 6) {
                VStack (spacing: 8) {
                    SectionHeader(title: "Milestones", subtitle: "Track your listening milestones")
                    
                    TabView(selection: $selectedMilestonePage) {
                        ShowMilestones(
                            title: "Artists",
                            milestoneData: artistsMilestoneData
                        )
                            .tag(0)
                        ShowMilestones(
                            title: "Albums",
                            milestoneData: albumsMilestoneData
                        )
                            .tag(1)
                        ShowMilestones(
                            title: "Songs",
                            milestoneData: songsMilestoneData
                        )
                            .tag(2)
                    }
                    .frame(height: 240)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Custom dots
                    HStack(spacing: 8) {
                        ForEach(0..<3) { idx in
                            Circle()
                                .fill(idx == selectedMilestonePage ? Color.resonatePurple : Color.gray.opacity(0.35))
                                .frame(width: idx == selectedMilestonePage ? 10 : 7, height: idx == selectedMilestonePage ? 10 : 7)
                                .scaleEffect(idx == selectedMilestonePage ? 1.05 : 1.0)
                                .animation(.easeOut(duration: 0.18), value: selectedMilestonePage)
                        }
                    }
                    .padding(.top, 8)
                }
                
                VStack (spacing: 10) {
                    SectionHeader(title: "Library Stats", subtitle: "Your music collection at a glance")
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            StatContainerView(title: "Artists", value: artistStats.count.formatted())
                            StatContainerView(title: "Albums", value: albumStats.count.formatted())
                        }
                        HStack(spacing: 6) {
                            StatContainerView(title: "Songs", value: songs.count.formatted())
                            StatContainerView(title: "Playlists", value: playlists.count.formatted())
                        }
                    }
                }

            }
            .task {
                updateSongsMilestones()
                updateAlbumsMilestones()
                updateArtistsMilestones()
            }
            .onChange(of: songs) { oldValue, newValue in
                updateSongsMilestones()
            }
            .onChange(of: albumStats) { oldValue, newValue in
                updateAlbumsMilestones()
            }
            .onChange(of: artistStats) { oldValue, newValue in
                updateArtistsMilestones()
            }
        }
    }

    func updateSongsMilestones() {
        let thresholds = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000]
        var data: [Int: Int] = [:]
        
        for threshold in thresholds {
            data[threshold] = songs.filter { ($0.playCount ?? 0) >= threshold }.count
        }
        
        songsMilestoneData = data
    }

    func updateAlbumsMilestones() {
        let thresholds = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000]
        var data: [Int: Int] = [:]
        
        for threshold in thresholds {
            data[threshold] = albumStats.filter { $0.totalPlayCount >= threshold }.count
        }
        
        albumsMilestoneData = data
    }

    func updateArtistsMilestones() {
        let thresholds = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000]
        var data: [Int: Int] = [:]
        
        for threshold in thresholds {
            data[threshold] = artistStats.filter { $0.totalPlayCount >= threshold }.count
        }
        
        artistsMilestoneData = data
    }
}