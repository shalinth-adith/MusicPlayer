import SwiftUI

struct PlayerControlsView: View {

    @EnvironmentObject var playerVM: PlayerViewModel

    var body: some View {
        VStack(spacing: 0) {
            seekSection
            statusStrip
            transportRow
            volumeRow
        }
        .background(Theme.controlsBg.ignoresSafeArea(edges: .bottom))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Theme.bevelLight),
            alignment: .top
        )
    }

    // MARK: - Seek Section (groove track + time labels)

    private var seekSection: some View {
        SeekBarView()
            .padding(.top, 8)
            .padding(.bottom, 2)
    }

    // MARK: - Status Strip

    private var statusStrip: some View {
        HStack(spacing: 6) {
            Image(systemName: playerVM.isPlaying ? "play.fill" : "stop.fill")
                .font(.system(size: 7))
                .foregroundStyle(playerVM.isPlaying ? Theme.seekGreen : Theme.subtext)

            MarqueeText(
                text: playerVM.currentSong.map { "\($0.title)   —   \($0.artist)" } ?? "NOT PLAYING",
                font: .system(size: 10),
                color: playerVM.isPlaying ? Theme.text : Theme.subtext,
                speed: 35
            )
            .frame(height: 14)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 5)
        .background(Theme.panel.opacity(0.6))
        .overlay(
            Rectangle().frame(height: 1).foregroundStyle(Theme.bevelDark),
            alignment: .bottom
        )
    }

    // MARK: - Transport Row

    private var transportRow: some View {
        HStack(spacing: 0) {
            Spacer()

            // Shuffle
            circleBtn(icon: "shuffle", diameter: 34, isActive: playerVM.isShuffle, iconSize: 12) {
                playerVM.toggleShuffle()
            }

            Spacer()

            // Previous
            circleBtn(icon: "backward.end.fill", diameter: 40, iconSize: 14) {
                playerVM.previous()
            }

            Spacer()

            // Play / Pause — primary large button
            Button {
                playerVM.isPlaying ? playerVM.pause() : playerVM.resume()
            } label: {
                Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
            .buttonStyle(CircularBevelButtonStyle(diameter: 56))

            Spacer()

            // Next
            circleBtn(icon: "forward.end.fill", diameter: 40, iconSize: 14) {
                playerVM.next()
            }

            Spacer()

            // Repeat
            repeatBtn

            Spacer()
        }
        .padding(.vertical, 10)
    }

    // MARK: - Volume Row

    private var volumeRow: some View {
        HStack(spacing: 10) {
            Button { playerVM.toggleMute() } label: {
                Image(systemName: playerVM.isMuted ? "speaker.slash.fill" : "speaker.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.subtext)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)

            Slider(
                value: Binding(
                    get: { Double(playerVM.volume) },
                    set: { playerVM.setVolume(Float($0)) }
                ),
                in: 0...1
            )
            .tint(Theme.accent)
            .frame(maxWidth: .infinity)

            Button { playerVM.setVolume(1.0) } label: {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.subtext)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .padding(.top, 2)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func circleBtn(
        icon: String,
        diameter: CGFloat,
        isActive: Bool = false,
        iconSize: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(isActive ? Theme.accent : Theme.text)
        }
        .buttonStyle(DarkCircularButtonStyle(diameter: diameter))
    }

    private var repeatBtn: some View {
        Button { playerVM.cycleRepeat() } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "repeat")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(playerVM.repeatMode != .off ? Theme.accent : Theme.text)
                if playerVM.repeatMode == .one {
                    Text("1")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(Theme.accent)
                        .offset(x: 6, y: -4)
                }
            }
        }
        .buttonStyle(DarkCircularButtonStyle(diameter: 34))
    }
}

// MARK: - Preview

#Preview("Not playing") {
    PlayerControlsView()
        .environmentObject(PlayerViewModel())
}

#Preview("Playing") {
    let vm = PlayerViewModel()
    vm.currentSong = Song(title: "Neeye Oli", artist: "Santhosh Narayanan", duration: 301, bookmarkData: Data())
    vm.isPlaying = true
    vm.duration = 301
    vm.currentTime = 120
    return PlayerControlsView()
        .environmentObject(vm)
}
