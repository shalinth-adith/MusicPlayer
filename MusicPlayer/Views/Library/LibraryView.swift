import SwiftUI

struct LibraryView: View {

    @EnvironmentObject var libraryVM: LibraryViewModel
    @EnvironmentObject var sidebarVM: SidebarViewModel

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
                            SongRowView(song: song)
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
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundStyle(Theme.subtext)
            Text("No songs yet")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.text)
            Text("Tap Import in the sidebar to add songs from Files")
                .font(.system(size: 12))
                .foregroundStyle(Theme.subtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }
}
