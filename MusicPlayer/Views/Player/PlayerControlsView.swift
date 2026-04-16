import SwiftUI

struct PlayerControlsView: View {

    @EnvironmentObject var playerVM: PlayerViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Status bar — marquee track name
            statusBar

            // Seek bar
            SeekBarView()

            // Transport controls
            transportBar
        }
        .background(Theme.controlsBg)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Theme.bevelLight),
            alignment: .top
        )
    }

    // MARK: - Status Bar

    private var statusBar: some View {
        HStack(spacing: 6) {
            Image(systemName: playerVM.isPlaying ? "play.fill" : "stop.fill")
                .font(.system(size: 8))
                .foregroundStyle(playerVM.isPlaying ? Theme.seekGreen : Theme.subtext)

            MarqueeText(
                text: playerVM.currentSong.map { "\($0.title)   —   \($0.artist)" } ?? "Not Playing",
                font: .system(size: 11),
                color: Theme.text,
                speed: 35
            )
            .frame(height: 16)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(Theme.panel.opacity(0.8))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Theme.bevelDark),
            alignment: .bottom
        )
    }

    // MARK: - Transport Bar

    private var transportBar: some View {
        HStack(spacing: 0) {
            // Left: playback buttons
            HStack(spacing: 8) {
                chunkButton("backward.end.fill", size: 14)  { playerVM.previous() }
                chunkButton("stop.fill",          size: 14)  { playerVM.stop() }
                chunkButton("gobackward.10",      size: 14)  { playerVM.seekBackward10s() }

                // Main play/pause — larger, circular
                Button {
                    playerVM.isPlaying ? playerVM.pause() : playerVM.resume()
                } label: {
                    Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(CircularBevelButtonStyle())

                chunkButton("goforward.10",      size: 14)  { playerVM.seekForward10s() }
                chunkButton("forward.end.fill",  size: 14)  { playerVM.next() }
            }
            .padding(.leading, 10)

            Spacer()

            // Right: mute + volume + shuffle + repeat
            HStack(spacing: 6) {
                chunkButton(
                    playerVM.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill",
                    size: 12
                ) { playerVM.toggleMute() }

                // Volume slider — green fill
                Slider(
                    value: Binding(
                        get: { Double(playerVM.volume) },
                        set: { playerVM.setVolume(Float($0)) }
                    ),
                    in: 0...1
                )
                .tint(Theme.seekGreen)
                .frame(width: 72)

                chunkButton("shuffle", size: 12, isActive: playerVM.isShuffle) {
                    playerVM.toggleShuffle()
                }

                repeatChunkButton
            }
            .padding(.trailing, 10)
        }
        .padding(.vertical, 8)
        .background(Theme.controlsBg)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func chunkButton(
        _ icon: String,
        size: CGFloat,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(isActive ? Theme.accent : Theme.text)
                .frame(width: 32, height: 28)
        }
        .buttonStyle(BeveledButtonStyle(cornerRadius: 4))
    }

    private var repeatChunkButton: some View {
        Button { playerVM.cycleRepeat() } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "repeat")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(playerVM.repeatMode != .off ? Theme.accent : Theme.text)
                if playerVM.repeatMode == .one {
                    Text("1")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(Theme.accent)
                        .offset(x: 5, y: -4)
                }
            }
            .frame(width: 32, height: 28)
        }
        .buttonStyle(BeveledButtonStyle(cornerRadius: 4))
    }
}

// MARK: - Preview

#Preview("Not playing") {
    PlayerControlsView()
        .environmentObject(PlayerViewModel())
        .frame(width: 500)
}

#Preview("Playing") {
    let vm = PlayerViewModel()
    vm.currentSong = Song(title: "Ambience : Water", artist: "Nature Sounds", duration: 245, bookmarkData: Data())
    vm.isPlaying = true
    vm.duration = 245
    vm.currentTime = 60
    return PlayerControlsView()
        .environmentObject(vm)
        .frame(width: 500)
}
