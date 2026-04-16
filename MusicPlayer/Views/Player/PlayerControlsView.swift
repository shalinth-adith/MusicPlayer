import SwiftUI

struct PlayerControlsView: View {

    @EnvironmentObject var playerVM: PlayerViewModel

    var body: some View {
        VStack(spacing: 0) {
            Divider().background(Theme.border)

            // Row 1 — Now playing label
            HStack(spacing: 6) {
                Image(systemName: playerVM.isPlaying ? "play.fill" : "pause.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(Theme.accent)

                Text(playerVM.currentSong.map { "\($0.title) — \($0.artist)" } ?? "Not Playing")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Theme.sidebar.opacity(0.6))

            // Row 2 — Seek bar
            SeekBarView()
                .padding(.vertical, 4)
                .background(Theme.background)

            // Row 3 — Buttons
            HStack(spacing: 0) {
                // Playback buttons group
                HStack(spacing: 14) {
                    controlButton("backward.end.fill", size: 16) { playerVM.previous() }
                    controlButton("stop.fill",         size: 16) { playerVM.stop() }
                    controlButton("gobackward.10",     size: 16) { playerVM.seekBackward10s() }

                    // Play / Pause
                    Button {
                        playerVM.isPlaying ? playerVM.pause() : playerVM.resume()
                    } label: {
                        Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.text)
                            .frame(width: 36, height: 36)
                            .background(Theme.accent.opacity(0.25))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    controlButton("goforward.10",     size: 16) { playerVM.seekForward10s() }
                    controlButton("forward.end.fill", size: 16) { playerVM.next() }
                }
                .padding(.leading, 12)

                Spacer()

                // Right controls
                HStack(spacing: 10) {
                    // Mute
                    controlButton(playerVM.isMuted ? "speaker.slash.fill" : "speaker.fill", size: 14) {
                        playerVM.toggleMute()
                    }

                    // Volume slider
                    Slider(value: Binding(
                        get: { Double(playerVM.volume) },
                        set: { playerVM.setVolume(Float($0)) }
                    ), in: 0...1)
                    .tint(Theme.seekGreen)
                    .frame(width: 70)

                    // Shuffle
                    controlButton("shuffle", size: 14, isActive: playerVM.isShuffle) {
                        playerVM.toggleShuffle()
                    }

                    // Repeat
                    repeatButton
                }
                .padding(.trailing, 12)
            }
            .padding(.vertical, 8)
            .background(Theme.background)
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func controlButton(_ icon: String, size: CGFloat, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundStyle(isActive ? Theme.accent : Theme.subtext)
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
    }

    private var repeatButton: some View {
        Button { playerVM.cycleRepeat() } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "repeat")
                    .font(.system(size: 14))
                    .foregroundStyle(playerVM.repeatMode != .off ? Theme.accent : Theme.subtext)
                if playerVM.repeatMode == .one {
                    Text("1")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(Theme.accent)
                        .offset(x: 4, y: -4)
                }
            }
            .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
    }
}
