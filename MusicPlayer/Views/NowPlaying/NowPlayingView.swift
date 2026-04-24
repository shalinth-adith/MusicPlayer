import SwiftUI

struct NowPlayingView: View {

    @EnvironmentObject var playerVM: PlayerViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isDragging = false
    @State private var dragProgress: CGFloat = 0
    @State private var dragOffset: CGFloat = 0

    private var seekProgress: CGFloat {
        guard playerVM.duration > 0 else { return 0 }
        let t = isDragging ? dragProgress : CGFloat(playerVM.currentTime / playerVM.duration)
        return min(max(t, 0), 1)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Color(.systemBackground).ignoresSafeArea()

                if playerVM.currentSong != nil {
                    VStack(spacing: 0) {
                        artBanner(width: geo.size.width)
                            .gesture(
                                DragGesture()
                                    .onChanged { v in
                                        if v.translation.height > 0 { dragOffset = v.translation.height }
                                    }
                                    .onEnded { v in
                                        if v.translation.height > 80 { dismiss() }
                                        else { withAnimation(.spring()) { dragOffset = 0 } }
                                    }
                            )

                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                seekSection(width: geo.size.width - 48)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 14)

                                songInfoSection
                                    .padding(.top, 8)

                                transportRow
                                    .padding(.top, 14)

                                volumeRow
                                    .padding(.horizontal, 24)
                                    .padding(.top, 14)

                                airplayRow
                                    .padding(.top, 8)
                                    .padding(.horizontal, 24)

                                Divider().padding(.top, 10)

                                shuffleRepeatRow
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)

                                Divider()

                                lyricsRow
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)

                                Divider()

                                upNextSection
                                    .padding(.bottom, 40)
                            }
                        }
                    }

                    // Dismiss chevron overlaid on art
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.6), radius: 4)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 8)
                    .padding(.top, 8)

                } else {
                    emptyState
                }
            }
        }
        .offset(y: dragOffset)
        .animation(.interactiveSpring(), value: dragOffset)
    }

    // MARK: - Art Banner

    private func artBanner(width: CGFloat) -> some View {
        ZStack {
            if let data = playerVM.currentSong?.artworkData,
               let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: 230)
                    .clipped()
            } else {
                LinearGradient(
                    colors: placeholderGradient(for: playerVM.currentSong),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: width, height: 230)
            }
        }
        .frame(width: width, height: 230)
    }

    // MARK: - Seek Section

    private func seekSection(width: CGFloat) -> some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                let trackWidth = geo.size.width
                let thumbDiam: CGFloat = isDragging ? 14 : 12
                let thumbX = max(0, seekProgress * trackWidth - thumbDiam / 2)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 3)
                    Capsule()
                        .fill(Color(.systemGray3))
                        .frame(width: max(0, seekProgress * trackWidth), height: 3)
                    Circle()
                        .fill(Color(.systemGray2))
                        .frame(width: thumbDiam, height: thumbDiam)
                        .offset(x: thumbX)
                        .animation(.easeOut(duration: 0.08), value: isDragging)
                }
                .frame(height: 20)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { v in
                            isDragging = true
                            dragProgress = min(max(v.location.x / trackWidth, 0), 1)
                        }
                        .onEnded { v in
                            let p = min(max(v.location.x / trackWidth, 0), 1)
                            playerVM.seek(to: p * playerVM.duration)
                            isDragging = false
                        }
                )
            }
            .frame(height: 20)

            let currentT = isDragging ? dragProgress * playerVM.duration : playerVM.currentTime
            let remaining = max(0, playerVM.duration - currentT)
            HStack {
                Text(formatTime(currentT))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color(.systemGray))
                Spacer()
                Text("-" + formatTime(remaining))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color(.systemGray))
            }
        }
    }

    // MARK: - Song Info

    private var songInfoSection: some View {
        VStack(spacing: 3) {
            Text(playerVM.currentSong?.title ?? "")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(.label))
                .lineLimit(1)
                .multilineTextAlignment(.center)
            Text(playerVM.currentSong?.artist ?? "Unknown Artist")
                .font(.system(size: 15))
                .foregroundStyle(Theme.accent)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Transport

    private var transportRow: some View {
        HStack(spacing: 0) {
            Spacer()

            Button { playerVM.previous() } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Color(.label))
                    .frame(width: 72, height: 56)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                playerVM.isPlaying ? playerVM.pause() : playerVM.resume()
            } label: {
                Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 44))
                    .offset(x: playerVM.isPlaying ? 0 : 3)
                    .foregroundStyle(Color(.label))
                    .frame(width: 72, height: 56)
            }
            .buttonStyle(.plain)

            Spacer()

            Button { playerVM.next() } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Color(.label))
                    .frame(width: 72, height: 56)
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    // MARK: - Volume

    private var volumeRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "speaker.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color(.systemGray3))
            Slider(value: Binding(
                get: { Double(playerVM.volume) },
                set: { playerVM.setVolume(Float($0)) }
            ))
            .tint(Color(.systemGray2))
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color(.systemGray3))
        }
    }

    // MARK: - AirPlay Row

    private var airplayRow: some View {
        HStack(spacing: 0) {
            Spacer()
            Button { } label: {
                Image(systemName: "airplayvideo")
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.accent)
            }
            .buttonStyle(.plain)
            Spacer()
            Button { } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18))
                    .foregroundStyle(Theme.accent)
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }

    // MARK: - Shuffle + Repeat

    private var shuffleRepeatRow: some View {
        HStack(spacing: 12) {
            Button { playerVM.toggleShuffle() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Shuffle")
                        .font(.system(size: 15, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(playerVM.isShuffle ? Theme.accent : Color.clear)
                .foregroundStyle(playerVM.isShuffle ? .white : Theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(playerVM.isShuffle ? Color.clear : Theme.accent, lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)

            Button { playerVM.cycleRepeat() } label: {
                HStack(spacing: 8) {
                    Image(systemName: playerVM.repeatMode == .one ? "repeat.1" : "repeat")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Repeat")
                        .font(.system(size: 15, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(playerVM.repeatMode != .off ? Theme.accent : Color.clear)
                .foregroundStyle(playerVM.repeatMode != .off ? .white : Theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(playerVM.repeatMode != .off ? Color.clear : Theme.accent, lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Lyrics

    private var lyricsRow: some View {
        HStack {
            Text("Lyrics")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color(.label))
            Spacer()
            Button("Show") { }
                .font(.system(size: 15))
                .foregroundStyle(Theme.accent)
                .buttonStyle(.plain)
        }
    }

    // MARK: - Up Next

    private var upNextSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Up Next")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color(.label))
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 10)

            Divider()

            let upcoming = playerVM.queue.filter { $0.id != playerVM.currentSong?.id }.prefix(3)

            if upcoming.isEmpty {
                Text("Nothing up next")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.systemGray))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
            } else {
                ForEach(Array(upcoming)) { song in
                    HStack(spacing: 12) {
                        ZStack {
                            if let data = song.artworkData,
                               let img = UIImage(data: data) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipped()
                            } else {
                                LinearGradient(
                                    colors: placeholderGradient(for: song),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(width: 44, height: 44)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(song.title)
                                .font(.system(size: 15))
                                .foregroundStyle(Color(.label))
                                .lineLimit(1)
                            Text(song.artist)
                                .font(.system(size: 13))
                                .foregroundStyle(Color(.systemGray))
                                .lineLimit(1)
                        }

                        Spacer()

                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(.systemGray3))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)

                    Divider().padding(.leading, 76)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "music.note")
                .font(.system(size: 64, weight: .thin))
                .foregroundStyle(Color(.tertiaryLabel))
            Text("No song selected")
                .font(.system(size: 18, weight: .thin))
                .foregroundStyle(Color(.label))
            Text("Go to Artists to play a song")
                .font(.system(size: 13))
                .foregroundStyle(Color(.systemGray))
            Spacer()
        }
    }

    // MARK: - Helpers

    private static let gradients: [(Color, Color)] = [
        (Color(hex: "F0A857"), Color(hex: "C8852A")),
        (Color(hex: "4ECDC4"), Color(hex: "6C90BB")),
        (Color(hex: "89B9F0"), Color(hex: "C9A8E0")),
        (Color(hex: "8FA3E8"), Color(hex: "B0C4F5")),
        (Color(hex: "C9A8E0"), Color(hex: "E899A8")),
        (Color(hex: "F08080"), Color(hex: "F5B8C0")),
        (Color(hex: "DA8FA8"), Color(hex: "E8C0A0")),
        (Color(hex: "6DD5FA"), Color(hex: "2980B9")),
    ]

    private func placeholderGradient(for song: Song?) -> [Color] {
        guard let song else { return [Color(hex: "F0A857"), Color(hex: "C8852A")] }
        let i = abs(song.id.hashValue) % Self.gradients.count
        return [Self.gradients[i].0, Self.gradients[i].1]
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let t = max(0, time)
        return String(format: "%d:%02d", Int(t) / 60, Int(t) % 60)
    }
}

// MARK: - Previews

#Preview("Empty") {
    NowPlayingView()
        .environmentObject(PlayerViewModel())
        .environmentObject(ThemeManager())
}

#Preview("With song") {
    let vm = PlayerViewModel()
    vm.currentSong = Song(title: "Experience", artist: "Victoria Monét", duration: 217, bookmarkData: Data())
    vm.duration = 217
    vm.currentTime = 91
    vm.isPlaying = true
    return NowPlayingView()
        .environmentObject(vm)
        .environmentObject(ThemeManager())
}
