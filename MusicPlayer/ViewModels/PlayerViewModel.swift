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

    private let audioService: any AudioPlayerServiceProtocol
    private var timer: AnyCancellable?
    private var currentIndex: Int = 0
    private let playbackSongKey     = "playback_song_id"
    private let playbackPositionKey = "playback_position"
    private var pendingSeekPosition: TimeInterval?
    private var resolvedURLCache: [UUID: URL] = [:]

    // MARK: - Init

    init(audioService: any AudioPlayerServiceProtocol = AudioPlayerService()) {
        self.audioService = audioService
        audioService.configureAudioSession()
        audioService.onPlaybackFinished = { [weak self] in
            Task { @MainActor in self?.handlePlaybackFinished() }
        }
        audioService.onDurationReady = { [weak self] d in
            Task { @MainActor in
                self?.duration = d
                if let pos = self?.pendingSeekPosition, pos > 0 {
                    self?.seek(to: pos)
                    self?.pendingSeekPosition = nil
                }
            }
        }
        audioService.onInterruptionEnded = { [weak self] in Task { @MainActor in self?.resume() } }
        audioService.registerRemoteCommands(
            onPlay:     { [weak self] in Task { @MainActor in self?.resume() } },
            onPause:    { [weak self] in Task { @MainActor in self?.pause() } },
            onNext:     { [weak self] in Task { @MainActor in self?.next() } },
            onPrevious: { [weak self] in Task { @MainActor in self?.previous() } }
        )
    }

    // MARK: - Playback Controls

    func play(_ song: Song) {
        guard let url = resolvedURLCache[song.id] ?? song.resolvedURL else { return }
        do {
            try audioService.load(url: url)
            audioService.setVolume(isMuted ? 0 : volume)
            audioService.play()
            currentSong = song
            duration = 0       // will be set by onDurationReady once AVPlayer parses the file
            currentTime = 0
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

    // MARK: - Playback State Persistence

    func savePlaybackState() {
        guard let song = currentSong else { return }
        UserDefaults.standard.set(song.id.uuidString, forKey: playbackSongKey)
        UserDefaults.standard.set(audioService.currentTime, forKey: playbackPositionKey)
    }

    func restorePlaybackState(from songs: [Song]) {
        guard let idString = UserDefaults.standard.string(forKey: playbackSongKey),
              let id = UUID(uuidString: idString),
              let song = songs.first(where: { $0.id == id }) else { return }
        let position = UserDefaults.standard.double(forKey: playbackPositionKey)
        pendingSeekPosition = position > 0 ? position : nil
        play(song)
    }

    // MARK: - Queue Management

    func setQueue(_ songs: [Song], playingIndex index: Int = 0) {
        resolvedURLCache = [:]
        queue = songs
        currentIndex = index
        prefetchURLs(for: songs)
        if !songs.isEmpty { play(songs[index]) }
    }

    private func prefetchURLs(for songs: [Song]) {
        Task.detached(priority: .userInitiated) { [weak self] in
            var cache: [UUID: URL] = [:]
            for song in songs {
                if let url = song.resolvedURL { cache[song.id] = url }
            }
            await MainActor.run { self?.resolvedURLCache.merge(cache) { _, new in new } }
        }
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
                // Fallback: pick up duration if KVO fired before the callback was wired
                if self.duration <= 0 {
                    let d = self.audioService.duration
                    if d > 0 { self.duration = d }
                }
            }
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}
