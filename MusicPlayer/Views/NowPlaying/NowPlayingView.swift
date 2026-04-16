import SwiftUI

struct NowPlayingView: View {

    @EnvironmentObject var playerVM: PlayerViewModel

    var body: some View {
        ZStack {
            Theme.background

            if let song = playerVM.currentSong {
                VStack(spacing: 20) {
                    // Album art in WMP9-style inset panel
                    Group {
                        if let data = song.artworkData, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                        } else {
                            placeholderArt
                        }
                    }
                    .frame(width: 240, height: 240)
                    .insetPanel(cornerRadius: 4)
                    .shadow(color: .black.opacity(0.6), radius: 16, x: 0, y: 6)

                    // Song info
                    VStack(spacing: 5) {
                        Text(song.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.text)
                            .lineLimit(1)
                        Text(song.artist)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.subtext)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(maxWidth: 260)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.panel)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Theme.border, lineWidth: 1)
                            )
                    )
                }
                .padding()
            } else {
                emptyState
            }
        }
    }

    private var placeholderArt: some View {
        ZStack {
            Theme.controlsBg
            VStack(spacing: 8) {
                Image(systemName: "film")
                    .font(.system(size: 52))
                    .foregroundStyle(Theme.accent.opacity(0.4))
                Image(systemName: "music.note")
                    .font(.system(size: 24))
                    .foregroundStyle(Theme.subtext.opacity(0.4))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.controlsBg)
                    .frame(width: 160, height: 160)
                VStack(spacing: 8) {
                    Image(systemName: "film")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.accent.opacity(0.3))
                    Image(systemName: "music.note")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.subtext.opacity(0.3))
                }
            }
            .insetPanel(cornerRadius: 4)

            VStack(spacing: 4) {
                Text("No song selected")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.subtext)
                Text("Go to Library to import and play songs")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.subtext.opacity(0.6))
            }
        }
    }
}

// MARK: - Preview

#Preview("Empty state") {
    NowPlayingView()
        .environmentObject(PlayerViewModel())
        .frame(width: 400, height: 400)
}

#Preview("With song") {
    let vm = PlayerViewModel()
    vm.currentSong = Song(title: "Ambience : Water", artist: "Nature Sounds", duration: 245, bookmarkData: Data())
    vm.duration = 245
    vm.currentTime = 60
    return NowPlayingView()
        .environmentObject(vm)
        .frame(width: 400, height: 400)
}
