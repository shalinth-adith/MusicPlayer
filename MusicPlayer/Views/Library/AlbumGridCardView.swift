import SwiftUI

struct AlbumGridCardView: View {

    let song: Song
    let isPlaying: Bool

    private static let gradients: [(Color, Color)] = [
        (Color(hex: "4ECDC4"), Color(hex: "6C90BB")),  // teal → steel blue
        (Color(hex: "89B9F0"), Color(hex: "C9A8E0")),  // sky blue → lavender
        (Color(hex: "8FA3E8"), Color(hex: "B0C4F5")),  // blue-purple → light blue
        (Color(hex: "C9A8E0"), Color(hex: "E899A8")),  // lavender → rose
        (Color(hex: "F08080"), Color(hex: "F5B8C0")),  // salmon → blush
        (Color(hex: "F0A857"), Color(hex: "E8C853")),  // amber → gold
        (Color(hex: "6DD5FA"), Color(hex: "2980B9")),  // light blue → deep blue
        (Color(hex: "DA8FA8"), Color(hex: "E8C0A0")),  // dusty rose → peach
    ]

    private static let genres = ["INDIE", "FOLK", "AMBIENT", "ELECTRONIC", "POP", "JAZZ", "ROCK", "R&B"]

    private var gradientColors: (Color, Color) {
        let index = abs(song.id.hashValue) % Self.gradients.count
        return Self.gradients[index]
    }

    private var genreLabel: String {
        let index = abs(song.id.hashValue) % Self.genres.count
        return Self.genres[index]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            artSquare
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(.label))
                    .lineLimit(2)
                Text(song.artist)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineLimit(1)
            }
        }
    }

    private var artSquare: some View {
        ZStack(alignment: .bottomLeading) {
            if let data = song.artworkData, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                LinearGradient(
                    colors: [gradientColors.0, gradientColors.1],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            Text(genreLabel)
                .font(.system(size: 11, weight: .semibold))
                .kerning(0.8)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPlaying ? Theme.accent : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    let songs = [
        Song(title: "Halcyon Days", artist: "Orion Bell", duration: 240, bookmarkData: Data()),
        Song(title: "Paper Moon",   artist: "June Harbor", duration: 198, bookmarkData: Data()),
        Song(title: "Slow Light",   artist: "Mira Quell",  duration: 312, bookmarkData: Data()),
        Song(title: "Neon Field",   artist: "Kiyo",        duration: 275, bookmarkData: Data()),
    ]
    return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        ForEach(songs) { song in
            AlbumGridCardView(song: song, isPlaying: false)
        }
    }
    .padding()
}
