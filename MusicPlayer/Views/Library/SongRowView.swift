import SwiftUI

struct SongRowView: View {

    let song: Song

    var body: some View {
        HStack(spacing: 10) {
            // Art thumbnail
            Group {
                if let data = song.artworkData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Theme.sidebar
                        Image(systemName: "music.note")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.subtext)
                    }
                }
            }
            .frame(width: 40, height: 40)
            .cornerRadius(4)
            .clipped()

            // Title & artist
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.subtext)
                    .lineLimit(1)
            }

            Spacer()

            // Duration
            Text(song.formattedDuration)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Theme.subtext)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .listRowBackground(Theme.background)
    }
}
