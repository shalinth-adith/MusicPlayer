import SwiftUI

struct NowPlayingView: View {

    @EnvironmentObject var playerVM: PlayerViewModel

    var body: some View {
        ZStack {
            Theme.background

            if let song = playerVM.currentSong {
                VStack(spacing: 16) {
                    // Album art
                    Group {
                        if let data = song.artworkData, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        } else {
                            placeholderArt
                        }
                    }
                    .frame(width: 220, height: 220)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 8)

                    // Song info
                    VStack(spacing: 4) {
                        Text(song.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.text)
                            .lineLimit(1)
                        Text(song.artist)
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.subtext)
                            .lineLimit(1)
                    }
                }
                .padding()
            } else {
                // Empty state
                VStack(spacing: 12) {
                    placeholderArt
                        .frame(width: 160, height: 160)
                    Text("No song selected")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.subtext)
                    Text("Go to Library and tap a song to play")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.subtext.opacity(0.6))
                }
            }
        }
    }

    private var placeholderArt: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Theme.sidebar)
            Image(systemName: "film")
                .font(.system(size: 48))
                .foregroundStyle(Theme.subtext)
        }
    }
}
