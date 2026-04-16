import Foundation

struct Song: Identifiable, Codable {
    let id: UUID
    var title: String
    var artist: String
    var duration: TimeInterval
    var bookmarkData: Data
    var artworkData: Data?

    init(id: UUID = UUID(), title: String, artist: String, duration: TimeInterval, bookmarkData: Data, artworkData: Data? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.duration = duration
        self.bookmarkData = bookmarkData
        self.artworkData = artworkData
    }

    var resolvedURL: URL? {
        var isStale = false
        let url = try? URL(
            resolvingBookmarkData: bookmarkData,
            options: .withoutUI,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        return url
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
