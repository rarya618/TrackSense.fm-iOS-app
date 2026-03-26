struct ArtistArtworkView: View {
    let artist: Artist

    var body: some View {
        
        if let artwork = artist.artwork {
            ArtworkImage(artwork, width: 50, height: 50)
                .cornerRadius(8)
        } else {
            Image(systemName: "music.note")
                .frame(width: 50, height: 50)
                .foregroundColor(.customPurple)
                .background(Color.customLightPurple)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}