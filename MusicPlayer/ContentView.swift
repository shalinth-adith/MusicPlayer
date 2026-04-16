import SwiftUI

struct ContentView: View {

    @EnvironmentObject var sidebarVM: SidebarViewModel

    var body: some View {
        HStack(spacing: 0) {
            // Left: sidebar
            SidebarView()

            // Center + Right: main panel and art thumbnail
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Main content area
                    Group {
                        switch sidebarVM.selectedTab {
                        case .nowPlaying: NowPlayingView()
                        case .library:    LibraryView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Top-right art thumbnail panel
                    ArtThumbnailView()
                }

                // Bottom: player controls
                PlayerControlsView()
            }
        }
        .background(Theme.background)
        .ignoresSafeArea()
    }
}

// MARK: - Preview

#Preview("Empty") {
    let playerVM  = PlayerViewModel()
    let sidebarVM = SidebarViewModel()
    let libraryVM = LibraryViewModel(playerViewModel: playerVM)
    return ContentView()
        .environmentObject(playerVM)
        .environmentObject(sidebarVM)
        .environmentObject(libraryVM)
}

#Preview("With song playing") {
    let playerVM  = PlayerViewModel()
    let sidebarVM = SidebarViewModel()
    let libraryVM = LibraryViewModel(playerViewModel: playerVM)
    let song = Song(title: "Ambience : Water", artist: "Nature Sounds", duration: 245, bookmarkData: Data())
    playerVM.currentSong = song
    playerVM.isPlaying = true
    playerVM.duration = 245
    playerVM.currentTime = 60
    libraryVM.songs = [
        song,
        Song(title: "Midnight Rain",   artist: "Taylor Swift", duration: 174, bookmarkData: Data()),
        Song(title: "Blinding Lights", artist: "The Weeknd",   duration: 200, bookmarkData: Data()),
    ]
    return ContentView()
        .environmentObject(playerVM)
        .environmentObject(sidebarVM)
        .environmentObject(libraryVM)
}
