import Foundation

struct Song: Identifiable, Codable {
    let id: UUID
    var title: String
    var artist: String
    var duration: TimeInterval
    var bookmarkData: Data           // file:// songs from Files app
    var artworkData: Data?
    var assetURLString: String?      // ipod-library:// songs from device Music library

    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        duration: TimeInterval,
        bookmarkData: Data,
        artworkData: Data? = nil,
        assetURLString: String? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.duration = duration
        self.bookmarkData = bookmarkData
        self.artworkData = artworkData
        self.assetURLString = assetURLString
    }

    /// Returns the playable URL — asset URL for media library songs, resolved bookmark for file songs.
    var resolvedURL: URL? {
        if let assetURLString {
            return URL(string: assetURLString)
        }
        guard !bookmarkData.isEmpty else { return nil }
        var isStale = false
        return try? URL(
            resolvingBookmarkData: bookmarkData,
            options: .withoutUI,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
