import SwiftUI

struct LibraryView: View {

    @EnvironmentObject var libraryVM: LibraryViewModel
    @EnvironmentObject var sidebarVM: SidebarViewModel
    @EnvironmentObject var playerVM: PlayerViewModel

    @State private var selectedTab: LibraryTab = .songs

    enum LibraryTab: String, CaseIterable {
        case songs     = "SONGS"
        case albums    = "ALBUMS"
        case artists   = "ARTISTS"
        case playlists = "PLAYLISTS"
    }

    var body: some View {
        VStack(spacing: 0) {
            tabSelector
            Divider()
                .background(Theme.bevelDark)

            ZStack {
                Theme.background.ignoresSafeArea()

                switch selectedTab {
                case .songs:
                    if libraryVM.songs.isEmpty {
                        emptyState
                    } else {
                        songList
                    }
                case .albums, .artists, .playlists:
                    comingSoon(selectedTab.rawValue.capitalized)
                }
            }
        }
        .background(Theme.background)
        .alert("Import Error", isPresented: Binding(
            get: { libraryVM.errorMessage != nil },
            set: { if !$0 { libraryVM.errorMessage = nil } }
        )) {
            Button("OK") { libraryVM.errorMessage = nil }
        } message: {
            Text(libraryVM.errorMessage ?? "")
        }
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 6) {
            ForEach(LibraryTab.allCases, id: \.self) { tab in
                Button { selectedTab = tab } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(selectedTab == tab ? .white : Theme.subtext)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            selectedTab == tab
                                ? Theme.accent
                                : Color.clear,
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.controlsBg)
    }

    // MARK: - Song List

    private var songList: some View {
        List {
            ForEach(libraryVM.songs) { song in
                Button {
                    libraryVM.selectSong(song)
                    sidebarVM.select(.nowPlaying)
                } label: {
                    SongRowView(
                        song: song,
                        isPlaying: playerVM.currentSong?.id == song.id && playerVM.isPlaying
                    )
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Theme.background)
            }
            .onDelete { offsets in
                libraryVM.deleteSongs(at: offsets)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Theme.background)
    }

    // MARK: - Empty / Coming Soon

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(Theme.accent.opacity(0.4))
            VStack(spacing: 6) {
                Text("Library Empty")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.text)
                Text("Tap + to import songs from Files")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.subtext)
            }
        }
    }

    private func comingSoon(_ label: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "music.note.list")
                .font(.system(size: 40, weight: .thin))
                .foregroundStyle(Theme.accent.opacity(0.3))
            Text("\(label) coming soon")
                .font(.system(size: 13))
                .foregroundStyle(Theme.subtext)
        }
    }
}

// MARK: - Preview

#Preview("Empty library") {
    let playerVM  = PlayerViewModel()
    let sidebarVM = SidebarViewModel()
    let libraryVM = LibraryViewModel(playerViewModel: playerVM)
    return LibraryView()
        .environmentObject(libraryVM)
        .environmentObject(sidebarVM)
        .environmentObject(playerVM)
}

#Preview("With songs") {
    let playerVM  = PlayerViewModel()
    let sidebarVM = SidebarViewModel()
    let libraryVM = LibraryViewModel(playerViewModel: playerVM)
    playerVM.currentSong = Song(title: "Ambience : Water", artist: "Nature Sounds", duration: 245, bookmarkData: Data())
    playerVM.isPlaying = true
    libraryVM.songs = [
        Song(title: "Ambience : Water",  artist: "Nature Sounds", duration: 245, bookmarkData: Data()),
        Song(title: "Midnight Rain",      artist: "Taylor Swift",  duration: 174, bookmarkData: Data()),
        Song(title: "Blinding Lights",    artist: "The Weeknd",    duration: 200, bookmarkData: Data()),
        Song(title: "Electric Dreams",    artist: "Synthwave Collective", duration: 262, bookmarkData: Data()),
        Song(title: "Neeye Oli",          artist: "Santhosh Narayanan",   duration: 301, bookmarkData: Data()),
    ]
    return LibraryView()
        .environmentObject(libraryVM)
        .environmentObject(sidebarVM)
        .environmentObject(playerVM)
}
