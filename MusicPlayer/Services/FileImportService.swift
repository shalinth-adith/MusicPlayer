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
