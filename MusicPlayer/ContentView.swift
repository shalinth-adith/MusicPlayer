import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {

    @EnvironmentObject var sidebarVM: SidebarViewModel
    @EnvironmentObject var libraryVM: LibraryViewModel
    @EnvironmentObject var playerVM: PlayerViewModel
    @EnvironmentObject var themeManager: ThemeManager

    @State private var showNowPlaying = false

    @ViewBuilder
    private var miniPlayerBar: some View {
        if playerVM.currentSong != nil {
            MiniPlayerBarView(showNowPlaying: $showNowPlaying)
                .background(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
        }
    }

    var body: some View {
        TabView(selection: $sidebarVM.selectedTab) {
            NavigationStack {
                RadioView()
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { miniPlayerBar }
            .tabItem { Label("Radio", systemImage: "radio") }
            .tag(AppTab.radio)

            PlaceholderTabView(title: "Playlists", icon: "music.note.list")
                .safeAreaInset(edge: .bottom, spacing: 0) { miniPlayerBar }
                .tabItem { Label("Playlists", systemImage: "music.note.list") }
                .tag(AppTab.playlists)

            NavigationStack {
                LibraryView()
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { miniPlayerBar }
            .tabItem { Label("Library", systemImage: "person.crop.rectangle.stack") }
            .tag(AppTab.artists)

            NavigationStack {
                SongsView()
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { miniPlayerBar }
            .tabItem { Label("Songs", systemImage: "music.note") }
            .tag(AppTab.songs)

            NavigationStack {
                MoreTabView()
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { miniPlayerBar }
            .tabItem { Label("More", systemImage: "ellipsis") }
            .tag(AppTab.more)
        }
        .tint(Theme.accent)
        .fullScreenCover(isPresented: $showNowPlaying) {
            NowPlayingView()
                .environmentObject(playerVM)
                .environmentObject(sidebarVM)
                .environmentObject(themeManager)
        }
        .onChange(of: playerVM.showNowPlayingSheet) { _, new in
            if new {
                showNowPlaying = true
                playerVM.showNowPlayingSheet = false
            }
        }
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
}

// MARK: - Songs Tab

private struct SongsView: View {
    @EnvironmentObject var libraryVM: LibraryViewModel
    @EnvironmentObject var playerVM: PlayerViewModel

    private var sortedSongs: [Song] {
        libraryVM.songs.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    var body: some View {
        Group {
            if libraryVM.songs.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "music.note")
                        .font(.system(size: 48, weight: .thin))
                        .foregroundStyle(Theme.accent.opacity(0.4))
                    Text("No Songs")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(.label))
                    Text("Add songs via the Library tab.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.secondaryLabel))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(sortedSongs) { song in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(song.title)
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color(.label))
                                    .lineLimit(1)
                                Text(song.artist)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(.secondaryLabel))
                                    .lineLimit(1)
                            }
                            Spacer()
                            if playerVM.currentSong?.id == song.id {
                                Image(systemName: playerVM.isPlaying ? "waveform" : "pause")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Theme.accent)
                            } else {
                                Text(song.formattedDuration)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(.secondaryLabel))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            libraryVM.selectSong(song)
                            playerVM.showNowPlayingSheet = true
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Songs")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - More Tab

private struct MoreTabView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        List {
            Section("Appearance") {
                HStack {
                    Label(
                        themeManager.isDark ? "Dark Mode" : "Light Mode",
                        systemImage: themeManager.isDark ? "moon.fill" : "sun.max.fill"
                    )
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { themeManager.isDark },
                        set: { _ in themeManager.toggle() }
                    ))
                    .labelsHidden()
                    .tint(Theme.accent)
                }
            }
        }
        .navigationTitle("More")
    }
}

// MARK: - Placeholder Tab

private struct PlaceholderTabView: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(Color(.tertiaryLabel))
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(.secondaryLabel))
            Text("Coming soon")
                .font(.system(size: 13))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
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
        .environmentObject(ThemeManager())
}

#Preview("With song playing") {
    let playerVM  = PlayerViewModel()
    let sidebarVM = SidebarViewModel()
    let libraryVM = LibraryViewModel(playerViewModel: playerVM)
    let song = Song(title: "Open Window", artist: "Ana Vero", duration: 217, bookmarkData: Data())
    playerVM.currentSong = song
    playerVM.isPlaying = true
    playerVM.duration = 217
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
        .environmentObject(ThemeManager())
}
