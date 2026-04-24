import SwiftUI

@main
struct MusicPlayerApp: App {

    @StateObject private var playerVM:  PlayerViewModel
    @StateObject private var sidebarVM: SidebarViewModel
    @StateObject private var libraryVM: LibraryViewModel
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var radioVM = RadioViewModel()

    @Environment(\.scenePhase) private var scenePhase

    init() {
        let player = PlayerViewModel()
        _playerVM  = StateObject(wrappedValue: player)
        _libraryVM = StateObject(wrappedValue: LibraryViewModel(playerViewModel: player))
        _sidebarVM = StateObject(wrappedValue: SidebarViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task { libraryVM.syncMediaLibrary() }
                .environmentObject(playerVM)
                .environmentObject(libraryVM)
                .environmentObject(sidebarVM)
                .environmentObject(themeManager)
                .environmentObject(radioVM)
                .preferredColorScheme(themeManager.isDark ? .dark : .light)
                // Folder picker sheet — presented from root so it always works
                .sheet(isPresented: $libraryVM.isFolderPickerPresented) {
                    DocumentFolderPicker { url in
                        libraryVM.isFolderPickerPresented = false
                        libraryVM.setMusicFolder(url: url)
                    }
                    .ignoresSafeArea()
                }
                .sheet(isPresented: $libraryVM.isDownloadsPickerPresented) {
                    DocumentFolderPicker { url in
                        libraryVM.isDownloadsPickerPresented = false
                        libraryVM.setDownloadsFolder(url: url)
                    }
                    .ignoresSafeArea()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                libraryVM.syncMediaLibrary()
                libraryVM.syncMusicFolder()
                libraryVM.syncDocuments()
                libraryVM.syncDownloadsFolder()
                libraryVM.startFolderWatcher()
                libraryVM.startDownloadsFolderWatcher()
                libraryVM.startMediaLibraryMonitoring()
            case .background:
                libraryVM.stopFolderWatcher()
                libraryVM.stopDownloadsFolderWatcher()
                libraryVM.stopMediaLibraryMonitoring()
                playerVM.savePlaybackState()
            default:
                break
            }
        }
    }
}
