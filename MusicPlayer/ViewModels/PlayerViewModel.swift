import Foundation
import Combine

@MainActor
final class PlayerViewModel: ObservableObject {

    // MARK: - Published State

    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 0.8
    @Published var isMuted: Bool = false
    @Published var isShuffle: Bool = false
    @Published var repeatMode: RepeatMode = .off
    @Published var queue: [Song] = []

    // MARK: - Private

    private let audioService: AudioPlayerService
    private var timer: AnyCancellable?
    private var currentIndex: Int = 0

    // MARK: - Init

    init(audioService: AudioPlayerService = AudioPlayerService()) {
        self.audioService = audioService
        audioService.configureAudioSession()
        audioService.onPlaybackFinished = { [weak self] in
            Task { @MainActor in self?.handlePlaybackFinished() }
        }
        audioService.registerRemoteCommands(
            onPlay:     { [weak self] in Task { @MainActor in self?.resume() } },
            onPause:    { [weak self] in Task { @MainActor in self?.pause() } },
            onNext:     { [weak self] in Task { @MainActor in self?.next() } },
            onPrevious: { [weak self] in Task { @MainActor in self?.previous() } }
        )
    }

    // MARK: - Playback Controls

    func play(_ song: Song) {
        guard let url = song.resolvedURL else { return }
        do {
            try audioService.load(url: url)
            audioService.setVolume(isMuted ? 0 : volume)
            audioService.play()
            currentSong = song
            duration = audioService.duration
            isPlaying = true
            if let idx = queue.firstIndex(where: { $0.id == song.id }) {
                currentIndex = idx
            }
            startTimer()
            audioService.updateNowPlaying(song: song)
        } catch {
            print("PlayerViewModel: failed to load song — \(error)")
        }
    }

    func pause() {
        audioService.pause()
        isPlaying = false
        stopTimer()
        if let song = currentSong { audioService.updateNowPlaying(song: song) }
    }

    func resume() {
        audioService.play()
        isPlaying = true
        startTimer()
        if let song = currentSong { audioService.updateNowPlaying(song: song) }
    }

    func stop() {
        audioService.stop()
        isPlaying = false
        currentTime = 0
        stopTimer()
    }

    func next() {
        guard !queue.isEmpty else { return }
        if isShuffle {
            let randomIndex = Int.random(in: 0..<queue.count)
            play(queue[randomIndex])
        } else {
            let nextIndex = (currentIndex + 1) % queue.count
            play(queue[nextIndex])
        }
    }

    func previous() {
        guard !queue.isEmpty else { return }
        // If more than 3s in, restart current track; otherwise go to previous
        if currentTime > 3 {
            seek(to: 0)
        } else {
            let prevIndex = (currentIndex - 1 + queue.count) % queue.count
            play(queue[prevIndex])
        }
    }

    func seek(to time: TimeInterval) {
        audioService.seek(to: time)
        currentTime = time
        if let song = currentSong { audioService.updateNowPlaying(song: song) }
    }

    func seekForward10s() {
        seek(to: min(currentTime + 10, duration))
    }

    func seekBackward10s() {
        seek(to: max(currentTime - 10, 0))
    }

    func toggleMute() {
        isMuted.toggle()
        audioService.setVolume(isMuted ? 0 : volume)
    }

    func setVolume(_ value: Float) {
        volume = value
        if !isMuted { audioService.setVolume(value) }
    }

    func toggleShuffle() {
        isShuffle.toggle()
    }

    func cycleRepeat() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
    }

    // MARK: - Queue Management

    func setQueue(_ songs: [Song], playingIndex index: Int = 0) {
        queue = songs
        currentIndex = index
        if !songs.isEmpty { play(songs[index]) }
    }

    // MARK: - Private Helpers

    private func handlePlaybackFinished() {
        switch repeatMode {
        case .one:
            if let song = currentSong { play(song) }
        case .all, .off:
            let isLast = currentIndex == queue.count - 1
            if isLast && repeatMode == .off {
                stop()
            } else {
                next()
            }
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isPlaying else { return }
                self.currentTime = self.audioService.currentTime
            }
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}
