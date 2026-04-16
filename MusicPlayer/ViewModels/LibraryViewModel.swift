import Foundation

@MainActor
final class LibraryViewModel: ObservableObject {

    // MARK: - Published State

    @Published var songs: [Song] = []
    @Published var isImporting: Bool = false
    @Published var errorMessage: String?

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
        songs.remove(atOffsets: offsets)
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
