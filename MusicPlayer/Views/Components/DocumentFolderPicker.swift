import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// Presents a UIDocumentPickerViewController that lets the user choose a folder.
/// The selected folder URL is returned via `onFolderSelected`.
struct DocumentFolderPicker: UIViewControllerRepresentable {

    var onFolderSelected: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onFolderSelected: onFolderSelected)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onFolderSelected: (URL) -> Void
        init(onFolderSelected: @escaping (URL) -> Void) {
            self.onFolderSelected = onFolderSelected
        }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onFolderSelected(url)
        }
    }
}
