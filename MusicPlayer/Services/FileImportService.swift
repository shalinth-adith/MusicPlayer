import AVFoundation
import Foundation

final class FileImportService {

    enum ImportError: Error, LocalizedError {
        case accessDenied
        case bookmarkFailed
        case metadataFailed

        var errorDescription: String? {
            switch self {
            case .accessDenied:     return "Could not access the selected file."
            case .bookmarkFailed:   return "Failed to create a persistent reference to the file."
            case .metadataFailed:   return "Could not read metadata from the file."
            }
        }
    }

    // MARK: - Music Folder Bookmark

    private let folderBookmarkKey = "music_folder_bookmark"
    private let audioExtensions = ["mp3", "m4a", "aac", "wav", "aiff", "aif", "flac", "alac"]

    /// Saves a security-scoped bookmark for the chosen folder so we can reopen it after restarts.
    func saveFolderBookmark(url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        if let data = try? url.bookmarkData(
            options: .minimalBookmark,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        ) {
            UserDefaults.standard.set(data, forKey: folderBookmarkKey)
        }
    }

    /// Returns true if a music folder has been saved.
    var hasSavedFolder: Bool {
        UserDefaults.standard.data(forKey: folderBookmarkKey) != nil
    }

    /// Returns the name of the saved folder, or nil if none saved.
    var savedFolderName: String? {
        guard let url = resolveFolder() else { return nil }
        return url.lastPathComponent
    }

    /// Resolves the saved bookmark back to a URL. Returns nil if no folder saved or bookmark stale.
    func resolveFolder() -> URL? {
        guard let data = UserDefaults.standard.data(forKey: folderBookmarkKey) else { return nil }
        var isStale = false
        return try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)
    }

    /// Opens and holds security scope on the saved folder. Caller must call stopFolderAccess when done.
    func startFolderAccess() -> URL? {
        guard let url = resolveFolder() else { return nil }
        guard url.startAccessingSecurityScopedResource() else { return nil }
        return url
    }

    func stopFolderAccess(_ url: URL) {
        url.stopAccessingSecurityScopedResource()
    }

    /// Scans the given folder (recursively one level) for audio files.
    func scanFolder(_ folderURL: URL) -> [URL] {
        guard folderURL.startAccessingSecurityScopedResource() else { return [] }
        defer { folderURL.stopAccessingSecurityScopedResource() }

        guard let items = try? FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        return items.filter { audioExtensions.contains($0.pathExtension.lowercased()) }
    }

    /// Imports a song from the music folder (uses security scope of the folder).
    func importFolderSong(from url: URL, folderURL: URL) throws -> Song {
        guard folderURL.startAccessingSecurityScopedResource() else {
            throw ImportError.accessDenied
        }
        defer { folderURL.stopAccessingSecurityScopedResource() }

        guard let bookmarkData = try? url.bookmarkData(
            options: .minimalBookmark,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        ) else {
            throw ImportError.bookmarkFailed
        }

        let (title, artist, duration, artworkData) = extractMetadata(from: url)
        return Song(
            title: title,
            artist: artist,
            duration: duration,
            bookmarkData: bookmarkData,
            artworkData: artworkData
        )
    }

    // MARK: - Documents Folder Scan

    /// Returns all audio file URLs found in the app's Documents directory.
    func scanDocumentsDirectory() -> [URL] {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let extensions = ["mp3", "m4a", "aac", "wav", "aiff", "aif", "flac", "alac"]
        guard let items = try? FileManager.default.contentsOfDirectory(
            at: docs,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        return items.filter { extensions.contains($0.pathExtension.lowercased()) }
    }

    /// Imports a single audio file from the app's Documents folder (no security scope needed).
    func importDocumentSong(from url: URL) throws -> Song {
        guard let bookmarkData = try? url.bookmarkData(
            options: .minimalBookmark,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        ) else {
            throw ImportError.bookmarkFailed
        }
        let (title, artist, duration, artworkData) = extractMetadata(from: url)
        return Song(
            title: title,
            artist: artist,
            duration: duration,
            bookmarkData: bookmarkData,
            artworkData: artworkData
        )
    }

    // MARK: - Import

    /// Imports a single audio file from a security-scoped URL (from fileImporter).
    /// Returns a fully populated Song ready to add to the library.
    func importSong(from url: URL) throws -> Song {
        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.accessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        // Create a persistent bookmark so we can reopen the file after app restarts
        guard let bookmarkData = try? url.bookmarkData(
            options: .minimalBookmark,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        ) else {
            throw ImportError.bookmarkFailed
        }

        let (title, artist, duration, artworkData) = extractMetadata(from: url)

        return Song(
            title: title,
            artist: artist,
            duration: duration,
            bookmarkData: bookmarkData,
            artworkData: artworkData
        )
    }

    // MARK: - Metadata Extraction

    private func extractMetadata(from url: URL) -> (title: String, artist: String, duration: TimeInterval, artworkData: Data?) {
        let asset = AVURLAsset(url: url)

        var title = url.deletingPathExtension().lastPathComponent
        var artist = "Unknown Artist"
        var artworkData: Data?

        let metadata = asset.commonMetadata

        for item in metadata {
            guard let key = item.commonKey else { continue }
            switch key {
            case .commonKeyTitle:
                if let value = item.stringValue, !value.isEmpty { title = value }
            case .commonKeyArtist:
                if let value = item.stringValue, !value.isEmpty { artist = value }
            case .commonKeyArtwork:
                if let data = item.dataValue { artworkData = data }
            default:
                break
            }
        }

        let duration = asset.duration.seconds.isNaN ? 0 : asset.duration.seconds

        return (title, artist, duration, artworkData)
    }
}
