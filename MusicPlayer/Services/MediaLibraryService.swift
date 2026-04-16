import MediaPlayer
import UIKit

/// Provides access to songs already on the device via MPMediaLibrary
/// (music synced with iTunes, downloaded via Apple Music, saved offline).
final class MediaLibraryService {

    // MARK: - Authorization

    var authorizationStatus: MPMediaLibraryAuthorizationStatus {
        MPMediaLibrary.authorizationStatus()
    }

    /// Requests access to the device music library.
    /// Calls completion on the main thread with whether access was granted.
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }

    // MARK: - Fetch

    /// Returns all songs available on the device (skips cloud-only items).
    func fetchAllSongs() -> [Song] {
        guard authorizationStatus == .authorized else { return [] }

        let query = MPMediaQuery.songs()
        // Only include items physically on the device
        query.addFilterPredicate(MPMediaPropertyPredicate(
            value: false,
            forProperty: MPMediaItemPropertyIsCloudItem
        ))

        guard let items = query.items else { return [] }

        return items.compactMap { item in
            guard let assetURL = item.assetURL else { return nil }

            let title  = item.title  ?? "Unknown Title"
            let artist = item.artist ?? "Unknown Artist"
            let duration = item.playbackDuration

            var artworkData: Data?
            if let artwork = item.artwork {
                let image = artwork.image(at: CGSize(width: 300, height: 300))
                artworkData = image?.jpegData(compressionQuality: 0.8)
            }

            return Song(
                title: title,
                artist: artist,
                duration: duration,
                bookmarkData: Data(),
                artworkData: artworkData,
                assetURLString: assetURL.absoluteString
            )
        }
    }
}
