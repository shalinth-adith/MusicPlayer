import SwiftUI

struct SongRowView: View {

    let song: Song
    var isPlaying: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Art thumbnail
            Group {
                if let data = song.artworkData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Theme.panel
                        Image(systemName: "music.note")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.subtext.opacity(0.6))
                    }
                }
            }
            .frame(width: 44, height: 44)
            .clipped()
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Theme.border, lineWidth: 1)
            )

            // Title & artist
            VStack(alignment: .leading, spacing: 3) {
                Text(song.title)
                    .font(.system(size: 13, weight: isPlaying ? .semibold : .medium))
                    .foregroundStyle(isPlaying ? Theme.text : Theme.text)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.subtext)
                    .lineLimit(1)
            }

            Spacer()

            // Playing indicator or duration
            if isPlaying {
                Image(systemName: "waveform")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.seekGreen)
                    .symbolEffect(.variableColor.iterative)
            } else {
                Text(song.formattedDuration)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Theme.subtext)
            }
        }
        .padding(.vertical, 8)
        .padding(.leading, isPlaying ? 9 : 12)
        .padding(.trailing, 12)
        .background(
            isPlaying
                ? Theme.accent.opacity(0.1)
                : Color.clear
        )
        .overlay(
            Rectangle()
                .frame(width: 3)
                .foregroundStyle(Theme.seekGreen)
                .opacity(isPlaying ? 1 : 0),
            alignment: .leading
        )
        .listRowBackground(Theme.background)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        SongRowView(song: Song(title: "Neeye Oli",      artist: "Santhosh Narayanan", duration: 301, bookmarkData: Data()), isPlaying: true)
        SongRowView(song: Song(title: "Electric Dreams", artist: "Synthwave Collective", duration: 262, bookmarkData: Data()))
        SongRowView(song: Song(title: "Midnight Jazz",   artist: "The Blue Notes",     duration: 225, bookmarkData: Data()))
        SongRowView(song: Song(title: "Blinding Lights", artist: "The Weeknd",          duration: 200, bookmarkData: Data()))
    }
    .background(Theme.background)
}
