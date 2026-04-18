import Foundation
import Combine

final class FolderWatcherService: NSObject, NSFilePresenter {

    nonisolated var presentedItemURL: URL? { _presentedItemURL }
    nonisolated let presentedItemOperationQueue: OperationQueue

    private var _presentedItemURL: URL?

    let changePublisher = PassthroughSubject<Void, Never>()

    override init() {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        q.qualityOfService = .utility
        presentedItemOperationQueue = q
        super.init()
    }

    deinit { stopWatching() }

    func startWatching(folderURL: URL) {
        if _presentedItemURL == folderURL { return }
        stopWatching()
        _presentedItemURL = folderURL
        NSFileCoordinator.addFilePresenter(self)
    }

    func stopWatching() {
        guard _presentedItemURL != nil else { return }
        NSFileCoordinator.removeFilePresenter(self)
        _presentedItemURL = nil
    }

    nonisolated func presentedSubitemDidAppear(at url: URL) {
        guard isAudioFile(url) else { return }
        changePublisher.send()
    }

    nonisolated func presentedSubitemDidChange(at url: URL) {
        guard isAudioFile(url) else { return }
        changePublisher.send()
    }

    private func isAudioFile(_ url: URL) -> Bool {
        ["mp3", "m4a", "aac", "wav", "aiff", "aif", "flac", "alac"]
            .contains(url.pathExtension.lowercased())
    }
}
