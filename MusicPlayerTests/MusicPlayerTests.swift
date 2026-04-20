import Foundation
import Testing
@testable import MusicPlayer

// MARK: - Mock

private final class MockAudioPlayerService: AudioPlayerServiceProtocol {
    var onPlaybackFinished: (() -> Void)?
    var onDurationReady: ((TimeInterval) -> Void)?
    var onInterruptionEnded: (() -> Void)?

    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var isPlaying: Bool = false

    var loadCallCount = 0
    var playCallCount = 0
    var pauseCallCount = 0
    var stopCallCount = 0
    var lastLoadedURL: URL?
    var seekTime: TimeInterval?
    var lastVolume: Float?

    func configureAudioSession() {}
    func load(url: URL) throws { loadCallCount += 1; lastLoadedURL = url }
    func play() { playCallCount += 1; isPlaying = true }
    func pause() { pauseCallCount += 1; isPlaying = false }
    func stop() { stopCallCount += 1; isPlaying = false }
    func seek(to time: TimeInterval) { seekTime = time; currentTime = time }
    func setVolume(_ volume: Float) { lastVolume = volume }
    func updateNowPlaying(song: Song) {}
    func registerRemoteCommands(
        onPlay: @escaping () -> Void,
        onPause: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onPrevious: @escaping () -> Void
    ) {}
}

// MARK: - Song Tests

@Suite("Song Model")
struct SongTests {

    private func makeSong(title: String = "Test", duration: TimeInterval = 0, assetURL: String? = nil) -> Song {
        Song(title: title, artist: "Artist", duration: duration, bookmarkData: Data(), assetURLString: assetURL)
    }

    @Test func formattedDurationZero() {
        #expect(makeSong(duration: 0).formattedDuration == "0:00")
    }

    @Test func formattedDurationSecondsOnly() {
        #expect(makeSong(duration: 45).formattedDuration == "0:45")
    }

    @Test func formattedDurationMinutesAndSeconds() {
        #expect(makeSong(duration: 65).formattedDuration == "1:05")
    }

    @Test func formattedDurationLong() {
        #expect(makeSong(duration: 3661).formattedDuration == "61:01")
    }

    @Test func resolvedURLFromAssetString() {
        let urlString = "ipod-library://item/item.mp3?id=123"
        let song = makeSong(assetURL: urlString)
        #expect(song.resolvedURL == URL(string: urlString))
    }

    @Test func resolvedURLNilWhenBothEmpty() {
        let song = makeSong()
        #expect(song.resolvedURL == nil)
    }

    @Test func codableRoundTrip() throws {
        let original = Song(
            title: "Title",
            artist: "Artist",
            duration: 180,
            bookmarkData: Data([1, 2, 3]),
            artworkData: Data([4, 5]),
            assetURLString: "test://item"
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Song.self, from: data)
        #expect(decoded.id == original.id)
        #expect(decoded.title == original.title)
        #expect(decoded.artist == original.artist)
        #expect(decoded.duration == original.duration)
        #expect(decoded.bookmarkData == original.bookmarkData)
        #expect(decoded.artworkData == original.artworkData)
        #expect(decoded.assetURLString == original.assetURLString)
    }

    @Test func codableRoundTripNilOptionals() throws {
        let original = Song(title: "T", artist: "A", duration: 0, bookmarkData: Data())
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Song.self, from: data)
        #expect(decoded.artworkData == nil)
        #expect(decoded.assetURLString == nil)
    }
}

// MARK: - PlayerViewModel Tests

@Suite("PlayerViewModel")
@MainActor
struct PlayerViewModelTests {

    private func makeVM() -> (PlayerViewModel, MockAudioPlayerService) {
        let mock = MockAudioPlayerService()
        let vm = PlayerViewModel(audioService: mock)
        return (vm, mock)
    }

    private func makeSong(_ title: String) -> Song {
        Song(title: title, artist: "Artist", duration: 120, bookmarkData: Data(),
             assetURLString: "test://\(title.lowercased())")
    }

    // MARK: Repeat mode cycling

    @Test func cycleRepeatOffToAll() {
        let (vm, _) = makeVM()
        #expect(vm.repeatMode == .off)
        vm.cycleRepeat()
        #expect(vm.repeatMode == .all)
    }

    @Test func cycleRepeatAllToOne() {
        let (vm, _) = makeVM()
        vm.cycleRepeat()
        vm.cycleRepeat()
        #expect(vm.repeatMode == .one)
    }

    @Test func cycleRepeatOneBackToOff() {
        let (vm, _) = makeVM()
        vm.cycleRepeat(); vm.cycleRepeat(); vm.cycleRepeat()
        #expect(vm.repeatMode == .off)
    }

    // MARK: Shuffle

    @Test func toggleShuffleOn() {
        let (vm, _) = makeVM()
        #expect(!vm.isShuffle)
        vm.toggleShuffle()
        #expect(vm.isShuffle)
    }

    @Test func toggleShuffleOff() {
        let (vm, _) = makeVM()
        vm.toggleShuffle(); vm.toggleShuffle()
        #expect(!vm.isShuffle)
    }

    // MARK: Mute & volume

    @Test func toggleMuteOn() {
        let (vm, _) = makeVM()
        #expect(!vm.isMuted)
        vm.toggleMute()
        #expect(vm.isMuted)
    }

    @Test func toggleMuteOff() {
        let (vm, _) = makeVM()
        vm.toggleMute(); vm.toggleMute()
        #expect(!vm.isMuted)
    }

    @Test func setVolumeUpdatesProperty() {
        let (vm, _) = makeVM()
        vm.setVolume(0.42)
        #expect(vm.volume == 0.42)
    }

    @Test func setVolumePassedToService() {
        let (vm, mock) = makeVM()
        vm.setVolume(0.7)
        #expect(mock.lastVolume == 0.7)
    }

    // MARK: Queue management

    @Test func setQueuePopulatesQueue() {
        let (vm, _) = makeVM()
        let songs = [makeSong("A"), makeSong("B"), makeSong("C")]
        vm.setQueue(songs, playingIndex: 0)
        #expect(vm.queue.count == 3)
    }

    @Test func setQueuePlaysCorrectIndex() {
        let (vm, _) = makeVM()
        let songs = [makeSong("A"), makeSong("B"), makeSong("C")]
        vm.setQueue(songs, playingIndex: 1)
        #expect(vm.currentSong?.title == "B")
    }

    @Test func nextAdvancesToNextSong() {
        let (vm, _) = makeVM()
        let songs = [makeSong("A"), makeSong("B"), makeSong("C")]
        vm.setQueue(songs, playingIndex: 0)
        vm.next()
        #expect(vm.currentSong?.title == "B")
    }

    @Test func nextWrapsAroundToFirst() {
        let (vm, _) = makeVM()
        let songs = [makeSong("A"), makeSong("B")]
        vm.setQueue(songs, playingIndex: 1)
        vm.next()
        #expect(vm.currentSong?.title == "A")
    }

    @Test func previousGoesToPreviousSong() {
        let (vm, _) = makeVM()
        let songs = [makeSong("A"), makeSong("B"), makeSong("C")]
        vm.setQueue(songs, playingIndex: 2)
        vm.previous()
        #expect(vm.currentSong?.title == "B")
    }

    @Test func previousWrapsAroundToLast() {
        let (vm, _) = makeVM()
        let songs = [makeSong("A"), makeSong("B")]
        vm.setQueue(songs, playingIndex: 0)
        vm.previous()
        #expect(vm.currentSong?.title == "B")
    }

    @Test func previousRestartsWhenOver3s() {
        let (vm, mock) = makeVM()
        let songs = [makeSong("A"), makeSong("B")]
        vm.setQueue(songs, playingIndex: 1)
        vm.currentTime = 10
        vm.previous()
        #expect(vm.currentSong?.title == "B")
        #expect(mock.seekTime == 0)
    }

    @Test func previousGoesToPreviousWhenUnder3s() {
        let (vm, _) = makeVM()
        let songs = [makeSong("A"), makeSong("B")]
        vm.setQueue(songs, playingIndex: 1)
        vm.currentTime = 2
        vm.previous()
        #expect(vm.currentSong?.title == "A")
    }

    // MARK: Playback state persistence

    @Test func saveAndRestorePlaybackState() {
        defer {
            UserDefaults.standard.removeObject(forKey: "playback_song_id")
            UserDefaults.standard.removeObject(forKey: "playback_position")
        }
        let song = makeSong("Persisted")
        let (vm1, _) = makeVM()
        vm1.setQueue([song], playingIndex: 0)
        vm1.savePlaybackState()

        let (vm2, _) = makeVM()
        vm2.restorePlaybackState(from: [song])
        #expect(vm2.currentSong?.id == song.id)
    }

    @Test func restorePlaybackStateNoOpWhenNoData() {
        UserDefaults.standard.removeObject(forKey: "playback_song_id")
        let (vm, _) = makeVM()
        vm.restorePlaybackState(from: [makeSong("X")])
        #expect(vm.currentSong == nil)
    }
}

// MARK: - LibraryViewModel Tests

@Suite("LibraryViewModel")
@MainActor
struct LibraryViewModelTests {

    private func makeSong(_ title: String, bookmarkSuffix: UInt8 = 0) -> Song {
        Song(title: title, artist: "Artist", duration: 60,
             bookmarkData: Data([bookmarkSuffix, bookmarkSuffix + 1]))
    }

    private func makeVM(songs: [Song] = []) -> LibraryViewModel {
        let playerVM = PlayerViewModel(audioService: MockAudioPlayerService())
        UserDefaults.standard.removeObject(forKey: "saved_library")
        let vm = LibraryViewModel(playerViewModel: playerVM)
        vm.songs = songs
        return vm
    }

    @Test func deleteSongRemovesCorrectEntry() {
        let a = makeSong("A", bookmarkSuffix: 0)
        let b = makeSong("B", bookmarkSuffix: 2)
        let c = makeSong("C", bookmarkSuffix: 4)
        let vm = makeVM(songs: [a, b, c])
        vm.deleteSong(b)
        #expect(vm.songs.count == 2)
        #expect(!vm.songs.contains { $0.id == b.id })
        #expect(vm.songs.contains { $0.id == a.id })
        #expect(vm.songs.contains { $0.id == c.id })
    }

    @Test func deleteSongsAtIndexSetRemovesCorrectEntries() {
        let a = makeSong("A", bookmarkSuffix: 0)
        let b = makeSong("B", bookmarkSuffix: 2)
        let c = makeSong("C", bookmarkSuffix: 4)
        let vm = makeVM(songs: [a, b, c])
        vm.deleteSongs(at: IndexSet([0, 2]))
        #expect(vm.songs.count == 1)
        #expect(vm.songs.first?.id == b.id)
    }

    @Test func deleteNonExistentSongLeavesLibraryUnchanged() {
        let a = makeSong("A", bookmarkSuffix: 0)
        let other = makeSong("Other", bookmarkSuffix: 10)
        let vm = makeVM(songs: [a])
        vm.deleteSong(other)
        #expect(vm.songs.count == 1)
    }

    @Test func libraryCodableRoundTrip() throws {
        let songs = [makeSong("Alpha", bookmarkSuffix: 0), makeSong("Beta", bookmarkSuffix: 2)]
        let data = try JSONEncoder().encode(songs)
        let decoded = try JSONDecoder().decode([Song].self, from: data)
        #expect(decoded.count == 2)
        #expect(decoded[0].title == "Alpha")
        #expect(decoded[1].title == "Beta")
    }

    @Test func duplicateBookmarkDetected() {
        let bookmarkData = Data([7, 8, 9])
        let existing = Song(title: "Existing", artist: "A", duration: 60, bookmarkData: bookmarkData)
        let vm = makeVM(songs: [existing])
        let isDuplicate = vm.songs.contains { $0.bookmarkData == bookmarkData }
        #expect(isDuplicate)
    }
}
