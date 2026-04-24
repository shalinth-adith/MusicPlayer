import Foundation
import Combine
import MediaPlayer

@MainActor
final class LibraryViewModel: ObservableObject {

    // MARK: - Published State

    @Published var songs: [Song] = []

    var artists: [(name: String, songs: [Song])] {
        let grouped = Dictionary(grouping: songs, by: \.artist)
        return grouped
            .map { (name: $0.key, songs: $0.value.sorted { $0.title < $1.title }) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    @Published var isImporting: Bool = false
    @Published var isFolderPickerPresented: Bool = false
    @Published var isDownloadsPickerPresented: Bool = false
    @Published var errorMessage: String?
    @Published var syncMessage: String?

    var musicFolderName: String? { fileImportService.savedFolderName }
    var hasMusicFolder: Bool { fileImportService.hasSavedFolder }

    var downloadsFolderName: String? { fileImportService.savedDownloadsFolderName }
    var hasDownloadsFolder: Bool { fileImportService.hasSavedDownloadsFolder }

    // MARK: - Private

    private let fileImportService: FileImportService
    private let mediaLibraryService: MediaLibraryService
    private let playerViewModel: PlayerViewModel
    private let storageKey = "saved_library"
    private let folderWatcher: FolderWatcherService
    private var watcherCancellable: AnyCancellable?
    private var activeFolderURL: URL?
    private let downloadsFolderWatcher: FolderWatcherService = FolderWatcherService()
    private var downloadsWatcherCancellable: AnyCancellable?
    private var activeDownloadsFolderURL: URL?
    private var mediaLibraryCancellable: AnyCancellable?

    // MARK: - Init

    init(
        fileImportService: FileImportService = FileImportService(),
        mediaLibraryService: MediaLibraryService = MediaLibraryService(),
        folderWatcher: FolderWatcherService = FolderWatcherService(),
        playerViewModel: PlayerViewModel
    ) {
        self.fileImportService = fileImportService
        self.mediaLibraryService = mediaLibraryService
        self.folderWatcher = folderWatcher
        self.playerViewModel = playerViewModel
        loadLibrary()
    }

    // MARK: - Device Music Library Sync

    /// Syncs songs from the device's Music library (iTunes sync, Apple Music downloads).
    /// Requests permission on first call; subsequent calls are automatic.
    func syncMediaLibrary() {
        switch mediaLibraryService.authorizationStatus {
        case .authorized:
            importMediaLibrarySongs()
        case .notDetermined:
            mediaLibraryService.requestAuthorization { [weak self] granted in
                if granted {
                    self?.importMediaLibrarySongs()
                    self?.startMediaLibraryMonitoring()
                }
            }
        default:
            break // denied — user must enable in Settings
        }
    }

    func startMediaLibraryMonitoring() {
        guard mediaLibraryService.authorizationStatus == .authorized else { return }
        mediaLibraryService.beginMonitoring()
        mediaLibraryCancellable = NotificationCenter.default
            .publisher(for: .MPMediaLibraryDidChange)
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in self?.syncMediaLibrary() }
            }
    }

    func stopMediaLibraryMonitoring() {
        mediaLibraryCancellable?.cancel()
        mediaLibraryCancellable = nil
        mediaLibraryService.endMonitoring()
    }

    private func importMediaLibrarySongs() {
        let service = mediaLibraryService
        Task.detached(priority: .userInitiated) { [weak self] in
            let mediaSongs = service.fetchAllSongs()
            guard !mediaSongs.isEmpty else { return }
            await MainActor.run { [weak self] in
                guard let self else { return }
                let existingAssetURLs = Set(self.songs.compactMap { $0.assetURLString })
                let newSongs = mediaSongs.filter { song in
                    guard let url = song.assetURLString else { return false }
                    return !existingAssetURLs.contains(url)
                }
                if !newSongs.isEmpty {
                    self.songs.append(contentsOf: newSongs)
                    self.saveLibrary()
                }
            }
        }
    }

    // MARK: - Music Folder Sync

    /// Called after user picks a folder. Saves the bookmark and triggers an immediate scan.
    func setMusicFolder(url: URL) {
        fileImportService.saveFolderBookmark(url: url)
        syncMusicFolder()
        startWatchingFolder()
    }

    func startFolderWatcher() {
        guard fileImportService.hasSavedFolder else { return }
        startWatchingFolder()
    }

    func stopFolderWatcher() {
        stopWatchingFolder()
    }

    private func startWatchingFolder() {
        stopWatchingFolder()
        guard let url = fileImportService.startFolderAccess() else { return }
        activeFolderURL = url
        folderWatcher.startWatching(folderURL: url)
        watcherCancellable = folderWatcher.changePublisher
            .debounce(for: .seconds(1.5), scheduler: DispatchQueue.global(qos: .utility))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                Task { @MainActor [weak self] in self?.syncMusicFolder() }
            }
    }

    private func stopWatchingFolder() {
        watcherCancellable?.cancel()
        watcherCancellable = nil
        folderWatcher.stopWatching()
        if let url = activeFolderURL {
            fileImportService.stopFolderAccess(url)
            activeFolderURL = nil
        }
    }

    /// Scans the saved music folder and imports any new audio files not already in the library.
    func syncMusicFolder() {
        let service = fileImportService
        let currentSongs = songs
        Task.detached(priority: .utility) { [weak self] in
            guard let folderURL = service.resolveFolder() else { return }
            let urls = service.scanFolder(folderURL)
            guard !urls.isEmpty else { return }

            let existingPaths = Set(currentSongs.compactMap { $0.resolvedURL?.resolvingSymlinksInPath().path })
            var added: [Song] = []
            for url in urls {
                guard !existingPaths.contains(url.resolvingSymlinksInPath().path) else { continue }
                if let song = try? service.importFolderSong(from: url, folderURL: folderURL) {
                    added.append(song)
                }
            }
            guard !added.isEmpty else { return }
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.songs.append(contentsOf: added)
                self.saveLibrary()
                self.syncMessage = "Added \(added.count) new song\(added.count == 1 ? "" : "s")"
            }
        }
    }

    // MARK: - Downloads Folder Sync

    func setDownloadsFolder(url: URL) {
        fileImportService.saveDownloadsFolderBookmark(url: url)
        syncDownloadsFolder()
        startWatchingDownloadsFolder()
    }

    func startDownloadsFolderWatcher() {
        guard fileImportService.hasSavedDownloadsFolder else { return }
        startWatchingDownloadsFolder()
    }

    func stopDownloadsFolderWatcher() {
        stopWatchingDownloadsFolder()
    }

    private func startWatchingDownloadsFolder() {
        stopWatchingDownloadsFolder()
        guard let url = fileImportService.startDownloadsFolderAccess() else { return }
        activeDownloadsFolderURL = url
        downloadsFolderWatcher.startWatching(folderURL: url)
        downloadsWatcherCancellable = downloadsFolderWatcher.changePublisher
            .debounce(for: .seconds(1.5), scheduler: DispatchQueue.global(qos: .utility))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                Task { @MainActor [weak self] in self?.syncDownloadsFolder() }
            }
    }

    private func stopWatchingDownloadsFolder() {
        downloadsWatcherCancellable?.cancel()
        downloadsWatcherCancellable = nil
        downloadsFolderWatcher.stopWatching()
        if let url = activeDownloadsFolderURL {
            fileImportService.stopDownloadsFolderAccess(url)
            activeDownloadsFolderURL = nil
        }
    }

    func syncDownloadsFolder() {
        let service = fileImportService
        let currentSongs = songs
        Task.detached(priority: .utility) { [weak self] in
            guard let folderURL = service.resolveDownloadsFolder() else { return }
            let urls = service.scanFolder(folderURL)
            guard !urls.isEmpty else { return }

            let existingPaths = Set(currentSongs.compactMap { $0.resolvedURL?.resolvingSymlinksInPath().path })
            var added: [Song] = []
            for url in urls {
                guard !existingPaths.contains(url.resolvingSymlinksInPath().path) else { continue }
                if let song = try? service.importFolderSong(from: url, folderURL: folderURL) {
                    added.append(song)
                }
            }
            guard !added.isEmpty else { return }
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.songs.append(contentsOf: added)
                self.saveLibrary()
                self.syncMessage = "Added \(added.count) new song\(added.count == 1 ? "" : "s")"
            }
        }
    }

    // MARK: - Documents Auto-Sync

    /// Scans the app's Documents folder and imports any audio files not already in the library.
    func syncDocuments() {
        let service = fileImportService
        let currentSongs = songs
        Task.detached(priority: .utility) { [weak self] in
            let urls = service.scanDocumentsDirectory()
            guard !urls.isEmpty else { return }

            let existingPaths = Set(currentSongs.compactMap { $0.resolvedURL?.resolvingSymlinksInPath().path })
            var added: [Song] = []
            for url in urls {
                guard !existingPaths.contains(url.resolvingSymlinksInPath().path) else { continue }
                if let song = try? service.importDocumentSong(from: url) {
                    added.append(song)
                }
            }
            guard !added.isEmpty else { return }
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.songs.append(contentsOf: added)
                self.saveLibrary()
            }
        }
    }

    // MARK: - Import

    func importSongs(from urls: [URL]) {
        var imported: [Song] = []
        for url in urls {
            do {
                let song = try fileImportService.importSong(from: url)
                // Avoid duplicates by bookmark data comparison
                if !songs.contains(where: { $0.bookmarkData == song.bookmarkData }) {
                    imported.append(song)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        songs.append(contentsOf: imported)
        saveLibrary()
    }

    // MARK: - Select & Delete

    func selectSong(_ song: Song) {
        playerViewModel.setQueue(songs, playingIndex: songs.firstIndex(where: { $0.id == song.id }) ?? 0)
    }

    func deleteSong(_ song: Song) {
        songs.removeAll { $0.id == song.id }
        saveLibrary()
    }

    func deleteSongs(at offsets: IndexSet) {
        songs = songs.enumerated()
            .filter { !offsets.contains($0.offset) }
            .map(\.element)
        saveLibrary()
    }

    // MARK: - Persistence

    private func saveLibrary() {
        if let data = try? JSONEncoder().encode(songs) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadLibrary() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Song].self, from: data) else { return }
        songs = decoded
        if playerViewModel.currentSong == nil {
            playerViewModel.restorePlaybackState(from: songs)
        }
    }
}
