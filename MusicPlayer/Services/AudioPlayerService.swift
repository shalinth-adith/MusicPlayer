import AVFoundation
import MediaPlayer

final class AudioPlayerService: NSObject {

    // MARK: - Properties

    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?
    private var statusObserver: NSKeyValueObservation?

    var onPlaybackFinished: (() -> Void)?
    var onDurationReady: ((TimeInterval) -> Void)?
    var onInterruptionEnded: (() -> Void)?

    var currentTime: TimeInterval {
        get {
            let t = player?.currentTime().seconds ?? 0
            return t.isNaN || t.isInfinite ? 0 : t
        }
        set {
            player?.seek(to: CMTime(seconds: newValue, preferredTimescale: 1000))
        }
    }

    var duration: TimeInterval {
        let d = player?.currentItem?.duration.seconds ?? 0
        return d.isNaN || d.isInfinite ? 0 : d
    }

    var isPlaying: Bool {
        (player?.rate ?? 0) > 0
    }

    // MARK: - Session Setup

    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioPlayerService: Failed to configure audio session — \(error)")
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        if type == .ended {
            let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                try? AVAudioSession.sharedInstance().setActive(true)
                onInterruptionEnded?()
            }
        }
    }

    // MARK: - Playback

    func load(url: URL) throws {
        if let obs = endObserver {
            NotificationCenter.default.removeObserver(obs)
        }
        statusObserver?.invalidate()

        let item = AVPlayerItem(url: url)
        if player == nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }

        // Fire onDurationReady once AVPlayer has parsed the file header
        statusObserver = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            guard item.status == .readyToPlay else { return }
            let d = item.duration.seconds
            guard d.isFinite, d > 0 else { return }
            DispatchQueue.main.async { self?.onDurationReady?(d) }
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.onPlaybackFinished?()
        }
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func stop() {
        player?.pause()
        player?.seek(to: .zero)
    }

    func seek(to time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1000))
    }

    func setVolume(_ volume: Float) {
        player?.volume = volume
    }

    // MARK: - Lock Screen / Remote Controls

    func updateNowPlaying(song: Song) {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artist,
            MPMediaItemPropertyPlaybackDuration: song.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
        if let artworkData = song.artworkData,
           let image = UIImage(data: artworkData) {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func registerRemoteCommands(
        onPlay: @escaping () -> Void,
        onPause: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onPrevious: @escaping () -> Void
    ) {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.isEnabled = true
        center.playCommand.addTarget { _ in onPlay(); return .success }
        center.pauseCommand.isEnabled = true
        center.pauseCommand.addTarget { _ in onPause(); return .success }
        center.nextTrackCommand.isEnabled = true
        center.nextTrackCommand.addTarget { _ in onNext(); return .success }
        center.previousTrackCommand.isEnabled = true
        center.previousTrackCommand.addTarget { _ in onPrevious(); return .success }
    }
}
