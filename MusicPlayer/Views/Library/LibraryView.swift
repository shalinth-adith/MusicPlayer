import SwiftUI

// MARK: - Library (Artist List)

struct LibraryView: View {

    @EnvironmentObject var libraryVM: LibraryViewModel
    @EnvironmentObject var sidebarVM: SidebarViewModel
    @EnvironmentObject var playerVM: PlayerViewModel

    var body: some View {
        Group {
            if libraryVM.artists.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(libraryVM.artists, id: \.name) { artist in
                        NavigationLink {
                            ArtistSongsView(artistName: artist.name, songs: artist.songs)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(artist.name)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(Color(.label))
                                Text("\(artist.songs.count) \(artist.songs.count == 1 ? "song" : "songs")")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(.secondaryLabel))
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Library")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { libraryVM.isFolderPickerPresented = true } label: {
                    Image(systemName: "folder.badge.plus")
                }
                .foregroundStyle(Theme.accent)
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

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(Theme.accent.opacity(0.4))
            VStack(spacing: 6) {
                Text("Library Empty")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(.label))
                Text("Point to a folder once and new songs sync automatically.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Button {
                libraryVM.isFolderPickerPresented = true
            } label: {
                Label("Set Music Folder", systemImage: "folder.badge.plus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            Button {
                libraryVM.isDownloadsPickerPresented = true
            } label: {
                Label("Sync Downloads Folder", systemImage: "arrow.down.circle")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Artist Songs Detail

struct ArtistSongsView: View {

    @EnvironmentObject var libraryVM: LibraryViewModel
    @EnvironmentObject var playerVM: PlayerViewModel

    let artistName: String
    let songs: [Song]

    var body: some View {
        List {
            ForEach(songs) { song in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(song.title)
                            .font(.system(size: 15))
                            .foregroundStyle(Color(.label))
                            .lineLimit(1)
                        Text(song.formattedDuration)
                            .font(.system(size: 12))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    Spacer()
                    if playerVM.currentSong?.id == song.id {
                        Image(systemName: playerVM.isPlaying ? "waveform" : "pause")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.accent)
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
        .navigationTitle(artistName)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Previews

#Preview("Empty library") {
    let playerVM  = PlayerViewModel()
    let sidebarVM = SidebarViewModel()
    let libraryVM = LibraryViewModel(playerViewModel: playerVM)
    return NavigationStack {
        LibraryView()
            .environmentObject(libraryVM)
            .environmentObject(sidebarVM)
            .environmentObject(playerVM)
    }
}

#Preview("With songs") {
    let playerVM  = PlayerViewModel()
    let sidebarVM = SidebarViewModel()
    let libraryVM = LibraryViewModel(playerViewModel: playerVM)
    playerVM.currentSong = Song(title: "Halcyon Days", artist: "Orion Bell", duration: 240, bookmarkData: Data())
    playerVM.isPlaying = true
    libraryVM.songs = [
        Song(title: "Halcyon Days",    artist: "Orion Bell",    duration: 240, bookmarkData: Data()),
        Song(title: "Paper Moon",      artist: "June Harbor",   duration: 198, bookmarkData: Data()),
        Song(title: "Slow Light",      artist: "Mira Quell",    duration: 312, bookmarkData: Data()),
        Song(title: "Midnight Rain",   artist: "Taylor Swift",  duration: 174, bookmarkData: Data()),
        Song(title: "Blinding Lights", artist: "The Weeknd",    duration: 200, bookmarkData: Data()),
    ]
    return NavigationStack {
        LibraryView()
            .environmentObject(libraryVM)
            .environmentObject(sidebarVM)
            .environmentObject(playerVM)
    }
}
