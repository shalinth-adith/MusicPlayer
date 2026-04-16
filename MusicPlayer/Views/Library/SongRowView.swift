import SwiftUI

struct SongRowView: View {

    let song: Song
    var isPlaying: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            // Art thumbnail — inset panel style
            Group {
                if let data = song.artworkData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Theme.controlsBg
                        Image(systemName: "music.note")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.subtext)
                    }
                }
            }
            .frame(width: 38, height: 38)
            .clipped()
            .insetPanel(cornerRadius: 3)

            // Title & artist
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.system(size: 12, weight: isPlaying ? .bold : .medium))
                    .foregroundStyle(isPlaying ? Theme.accent : Theme.text)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.subtext)
                    .lineLimit(1)
            }

            Spacer()

            // Playing indicator or duration
            if isPlaying {
                Image(systemName: "waveform")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.seekGreen)
                    .symbolEffect(.variableColor.iterative)
            } else {
                Text(song.formattedDuration)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Theme.subtext)
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(
            isPlaying
                ? Theme.accent.opacity(0.08)
                : Color.clear
        )
        .listRowBackground(Theme.background)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        SongRowView(song: Song(title: "Ambience : Water",  artist: "Nature Sounds", duration: 245, bookmarkData: Data()), isPlaying: true)
        SongRowView(song: Song(title: "Midnight Rain",      artist: "Taylor Swift",  duration: 174, bookmarkData: Data()))
        SongRowView(song: Song(title: "Blinding Lights",    artist: "The Weeknd",    duration: 200, bookmarkData: Data()))
    }
    .background(Theme.background)
}
