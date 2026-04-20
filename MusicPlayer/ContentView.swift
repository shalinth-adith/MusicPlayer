import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {

    @EnvironmentObject var sidebarVM: SidebarViewModel
    @EnvironmentObject var libraryVM: LibraryViewModel

    @State private var isSidebarOpen = false

    private let sidebarWidth: CGFloat = 180

    var body: some View {
        ZStack(alignment: .leading) {

            // MARK: — Main content (safe-area-aware)
            VStack(spacing: 0) {
                topBar
                Group {
                    switch sidebarVM.selectedTab {
                    case .nowPlaying: NowPlayingView()
                    case .library:    LibraryView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                PlayerControlsView()
            }

            // MARK: — Dim overlay
            if isSidebarOpen {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture { closeSidebar() }
                    .transition(.opacity)
            }

            // MARK: — Sidebar drawer
            SidebarView(onClose: closeSidebar)
                .frame(width: sidebarWidth)
                .ignoresSafeArea(edges: .vertical)
                .shadow(color: .black.opacity(0.5), radius: 16, x: 4, y: 0)
                .offset(x: isSidebarOpen ? 0 : -sidebarWidth)
                .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isSidebarOpen)
        }
        // Background bleeds into safe areas; ZStack content respects them
        .background(Theme.background.ignoresSafeArea())
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    let startedNearEdge = value.startLocation.x < 40
                    let swipedRight = value.translation.width > 60
                    let swipedLeft  = value.translation.width < -60
                    if startedNearEdge && swipedRight { openSidebar() }
                    else if swipedLeft { closeSidebar() }
                }
        )
        .fileImporter(
            isPresented: $libraryVM.isImporting,
            allowedContentTypes: [.audio, .mp3, .mpeg4Audio, .wav, .aiff],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls): libraryVM.importSongs(from: urls)
            case .failure(let error): libraryVM.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: — Top bar

    private var topBar: some View {
        ZStack {
            // Centered title
            Text(sidebarVM.selectedTab == .nowPlaying ? "NOW PLAYING" : "LIBRARY")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.text)
                .tracking(1.8)

            // Left / right actions
            HStack(spacing: 0) {
                if sidebarVM.selectedTab == .library {
                    // Back to Now Playing
                    Button { sidebarVM.select(.nowPlaying) } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.text)
                            .frame(width: 32, height: 28)
                    }
                    .buttonStyle(BeveledButtonStyle(cornerRadius: 14))
                } else {
                    Button { isSidebarOpen ? closeSidebar() : openSidebar() } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.text)
                            .frame(width: 32, height: 28)
                    }
                    .buttonStyle(BeveledButtonStyle(cornerRadius: 4))
                    .accessibilityLabel("Menu")
                }

                Spacer()

                if sidebarVM.selectedTab == .library {
                    // Search placeholder (wired to libraryVM search in future)
                    Button { } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.text)
                            .frame(width: 32, height: 28)
                    }
                    .buttonStyle(BeveledButtonStyle(cornerRadius: 14))
                } else {
                    Button { libraryVM.isImporting = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.text)
                            .frame(width: 32, height: 28)
                    }
                    .buttonStyle(BeveledButtonStyle(cornerRadius: 4))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Theme.controlsBg.ignoresSafeArea(edges: .top))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Theme.bevelDark),
            alignment: .bottom
        )
    }

    // MARK: — Helpers

    private func openSidebar() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            isSidebarOpen = true
        }
    }

    private func closeSidebar() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            isSidebarOpen = false
        }
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
