import SwiftUI

struct MiniPlayerBarView: View {

    @EnvironmentObject var playerVM: PlayerViewModel
    @Binding var showNowPlaying: Bool

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                thumbnail
                songInfo
                Spacer()
                playPauseButton
                nextButton
            }
            .padding(.horizontal, 12)
            .frame(height: 64)
            .contentShape(Rectangle())
            .onTapGesture { showNowPlaying = true }
        }
    }

    private var thumbnail: some View {
        ZStack {
            if let data = playerVM.currentSong?.artworkData, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                LinearGradient(
                    colors: [Theme.cardGradientStart, Theme.cardGradientEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .frame(width: 44, height: 44)
        .cornerRadius(8)
    }

    private var songInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(playerVM.currentSong?.title ?? "")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(.label))
                .lineLimit(1)
            Text(playerVM.currentSong?.artist ?? "")
                .font(.system(size: 12))
                .foregroundStyle(Color(.secondaryLabel))
                .lineLimit(1)
        }
    }

    private var playPauseButton: some View {
        Button {
            playerVM.isPlaying ? playerVM.pause() : playerVM.resume()
        } label: {
            Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color(.label))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }

    private var nextButton: some View {
        Button { playerVM.next() } label: {
            Image(systemName: "forward.end.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color(.label))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let playerVM = PlayerViewModel()
    playerVM.currentSong = Song(title: "Open Window", artist: "Ana Vero", duration: 210, bookmarkData: Data())
    playerVM.isPlaying = true
    return MiniPlayerBarView(showNowPlaying: .constant(false))
        .environmentObject(playerVM)
        .background(.ultraThinMaterial)
}
