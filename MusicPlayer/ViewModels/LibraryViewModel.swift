import Foundation
import Combine

@MainActor
final class LibraryViewModel: ObservableObject {

    // MARK: - Published State

    @Published var songs: [Song] = []
    @Published var isImporting: Bool = false
    @Published var isFolderPickerPresented: Bool = false
    @Published var errorMessage: String?
    @Published var syncMessage: String?

    var musicFolderName: String? { fileImportService.savedFolderName }
    var hasMusicFolder: Bool { fileImportService.hasSavedFolder }

    // MARK: - Private

    private let fileImportService: FileImportService
    private let playerViewModel: PlayerViewModel
    private let storageKey = "saved_library"

    // MARK: - Init

    init(fileImportService: FileImportService = FileImportService(),
         playerViewModel: PlayerViewModel) {
        self.fileImportService = fileImportService
        self.playerViewModel = playerViewModel
        loadLibrary()
    }

    // MARK: - Music Folder Sync

    /// Called after user picks a folder. Saves the bookmark and triggers an immediate scan.
    func setMusicFolder(url: URL) {
        fileImportService.saveFolderBookmark(url: url)
        syncMusicFolder()
    }

    /// Scans the saved music folder and imports any new audio files not already in the library.
    func syncMusicFolder() {
        guard let folderURL = fileImportService.resolveFolder() else { return }
        let urls = fileImportService.scanFolder(folderURL)
        guard !urls.isEmpty else { return }

        let existingPaths = Set(songs.compactMap { $0.resolvedURL?.path })
        var added: [Song] = []

        for url in urls {
            guard !existingPaths.contains(url.path) else { continue }
            if let song = try? fileImportService.importFolderSong(from: url, folderURL: folderURL) {
                added.append(song)
            }
        }

        if !added.isEmpty {
            songs.append(contentsOf: added)
            saveLibrary()
            syncMessage = "Added \(added.count) new song\(added.count == 1 ? "" : "s")"
        }
    }

    // MARK: - Documents Auto-Sync

    /// Scans the app's Documents folder and imports any audio files not already in the library.
    func syncDocuments() {
        let urls = fileImportService.scanDocumentsDirectory()
        guard !urls.isEmpty else { return }

        // Build a set of paths already tracked so we can skip duplicates
        let existingPaths = Set(songs.compactMap { $0.resolvedURL?.path })

        var added: [Song] = []
        for url in urls {
            guard !existingPaths.contains(url.path) else { continue }
            if let song = try? fileImportService.importDocumentSong(from: url) {
                added.append(song)
            }
        }

        if !added.isEmpty {
            songs.append(contentsOf: added)
            saveLibrary()
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
              let saved = try? JSONDecoder().decode([Song].self, from: data) else { return }
        songs = saved
    }
}
