import SwiftUI

struct LibraryView: View {

    @EnvironmentObject var libraryVM: LibraryViewModel
    @EnvironmentObject var sidebarVM: SidebarViewModel
    @EnvironmentObject var playerVM: PlayerViewModel

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if libraryVM.songs.isEmpty {
                emptyState
            } else {
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
                        .listRowSeparatorTint(Theme.border)
                        .listRowInsets(EdgeInsets())
                    }
                    .onDelete { offsets in
                        libraryVM.deleteSongs(at: offsets)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Theme.background)
            }
        }
        .alert("Import Error", isPresented: Binding(
            get: { libraryVM.errorMessage != nil },
            set: { if !$0 { libraryVM.errorMessage = nil } }
        )) {
            Button("OK") { libraryVM.errorMessage = nil }
        } message: {
            Text(libraryVM.errorMessage ?? "")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 44))
                .foregroundStyle(Theme.accent.opacity(0.4))
            VStack(spacing: 4) {
                Text("Library Empty")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.text)
                Text("Tap Import to add songs from Files")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.subtext)
            }
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
        .frame(width: 300, height: 400)
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
    ]
    return LibraryView()
        .environmentObject(libraryVM)
        .environmentObject(sidebarVM)
        .environmentObject(playerVM)
        .frame(width: 300, height: 400)
}
