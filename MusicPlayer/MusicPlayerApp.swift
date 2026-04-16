import SwiftUI

@main
struct MusicPlayerApp: App {

    @StateObject private var playerVM:  PlayerViewModel
    @StateObject private var sidebarVM: SidebarViewModel
    @StateObject private var libraryVM: LibraryViewModel

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
                .environmentObject(playerVM)
                .environmentObject(libraryVM)
                .environmentObject(sidebarVM)
                // Folder picker sheet — presented from root so it always works
                .sheet(isPresented: $libraryVM.isFolderPickerPresented) {
                    DocumentFolderPicker { url in
                        libraryVM.isFolderPickerPresented = false
                        libraryVM.setMusicFolder(url: url)
                    }
                    .ignoresSafeArea()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Sync saved music folder + Documents dir on every foreground
                libraryVM.syncMusicFolder()
                libraryVM.syncDocuments()
            }
        }
    }
}
