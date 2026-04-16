import SwiftUI

struct PlayerControlsView: View {

    @EnvironmentObject var playerVM: PlayerViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Row 1: status bar — marquee track name
            statusBar

            // Row 2: seek bar
            SeekBarView()

            // Row 3: main playback buttons (centred)
            playbackRow

            // Row 4: volume + extras
            extrasRow
        }
        .background(
            Theme.controlsBg
                .ignoresSafeArea(edges: .bottom)
        )
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

    // MARK: - Playback Row (prev / stop / -10 / play / +10 / next)

    private var playbackRow: some View {
        HStack(spacing: 10) {
            Spacer()
            btn("backward.end.fill",  size: 13) { playerVM.previous() }
            btn("gobackward.10",       size: 13) { playerVM.seekBackward10s() }

            // Play / pause — larger circular
            Button {
                playerVM.isPlaying ? playerVM.pause() : playerVM.resume()
            } label: {
                Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(CircularBevelButtonStyle())

            btn("goforward.10",       size: 13) { playerVM.seekForward10s() }
            btn("forward.end.fill",   size: 13) { playerVM.next() }
            btn("stop.fill",          size: 13) { playerVM.stop() }
            Spacer()
        }
        .padding(.vertical, 8)
    }

    // MARK: - Extras Row (mute | volume | shuffle | repeat)

    private var extrasRow: some View {
        HStack(spacing: 8) {
            btn(
                playerVM.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill",
                size: 12
            ) { playerVM.toggleMute() }

            Slider(
                value: Binding(
                    get: { Double(playerVM.volume) },
                    set: { playerVM.setVolume(Float($0)) }
                ),
                in: 0...1
            )
            .tint(Theme.seekGreen)
            .frame(maxWidth: .infinity)

            btn("shuffle", size: 12, isActive: playerVM.isShuffle) {
                playerVM.toggleShuffle()
            }

            repeatButton
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 6)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func btn(
        _ icon: String,
        size: CGFloat,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(isActive ? Theme.accent : Theme.text)
                .frame(width: 30, height: 26)
        }
        .buttonStyle(BeveledButtonStyle(cornerRadius: 4))
    }

    private var repeatButton: some View {
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
            .frame(width: 30, height: 26)
        }
        .buttonStyle(BeveledButtonStyle(cornerRadius: 4))
    }
}

// MARK: - Preview

#Preview("Not playing") {
    PlayerControlsView()
        .environmentObject(PlayerViewModel())
}

#Preview("Playing") {
    let vm = PlayerViewModel()
    vm.currentSong = Song(title: "Ambience : Water", artist: "Nature Sounds", duration: 245, bookmarkData: Data())
    vm.isPlaying = true
    vm.duration = 245
    vm.currentTime = 60
    return PlayerControlsView()
        .environmentObject(vm)
}
