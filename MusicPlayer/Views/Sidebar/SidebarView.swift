import SwiftUI

struct SidebarView: View {

    @EnvironmentObject var sidebarVM: SidebarViewModel
    @EnvironmentObject var libraryVM: LibraryViewModel

    private let items: [(tab: AppTab, label: String, icon: String)] = [
        (.nowPlaying, "Now Playing", "play.circle.fill"),
        (.library,    "Library",     "music.note.list")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "music.note")
                    .foregroundStyle(Theme.accent)
                    .font(.system(size: 14, weight: .bold))
                Text("MusicPlayer")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.text)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider().background(Theme.border)

            // Nav items
            ForEach(items, id: \.tab) { item in
                SidebarItemView(
                    label: item.label,
                    icon: item.icon,
                    isSelected: sidebarVM.selectedTab == item.tab
                ) {
                    sidebarVM.select(item.tab)
                }
            }

            // Import button
            SidebarItemView(
                label: "Import",
                icon: "plus.circle",
                isSelected: false
            ) {
                libraryVM.isImporting = true
            }

            Spacer()
        }
        .frame(width: 120)
        .background(Theme.sidebar)
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

// MARK: - Sidebar Item

private struct SidebarItemView: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // Active indicator bar
                Rectangle()
                    .fill(isSelected ? Theme.accent : Color.clear)
                    .frame(width: 3)

                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(isSelected ? Theme.accent : Theme.subtext)
                    Text(label)
                        .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Theme.text : Theme.subtext)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .background(isSelected ? Theme.background.opacity(0.4) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}
