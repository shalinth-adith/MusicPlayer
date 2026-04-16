import AVFoundation
import MediaPlayer

final class AudioPlayerService: NSObject {

    // MARK: - Properties

    private var player: AVAudioPlayer?

    /// Called when the current track finishes playing naturally
    var onPlaybackFinished: (() -> Void)?

    var currentTime: TimeInterval {
        get { player?.currentTime ?? 0 }
        set { player?.currentTime = newValue }
    }

    var duration: TimeInterval {
        player?.duration ?? 0
    }

    var isPlaying: Bool {
        player?.isPlaying ?? false
    }

    // MARK: - Session Setup

    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioPlayerService: Failed to configure audio session — \(error)")
        }
    }

    // MARK: - Playback

    func load(url: URL) throws {
        player?.stop()
        player = try AVAudioPlayer(contentsOf: url)
        player?.delegate = self
        player?.prepareToPlay()
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func stop() {
        player?.stop()
        player?.currentTime = 0
    }

    func seek(to time: TimeInterval) {
        player?.currentTime = time
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

// MARK: - AVAudioPlayerDelegate

extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            onPlaybackFinished?()
        }
    }
}
