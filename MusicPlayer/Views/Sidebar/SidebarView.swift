import SwiftUI

struct SidebarView: View {

    @EnvironmentObject var sidebarVM: SidebarViewModel
    @EnvironmentObject var libraryVM: LibraryViewModel
    var onClose: (() -> Void)? = nil

    private let items: [(tab: AppTab, label: String, icon: String)] = [
        (.nowPlaying, "Now\nPlaying", "play.circle.fill"),
        (.library,    "Library",     "music.note.list")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header logo — top safe area aware
            VStack(spacing: 4) {
                Image(systemName: "music.note")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.accent)
                Text("MUSIC")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.text)
                Text("PLAYER")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.subtext)
            }
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                Theme.controlsBg
                    .ignoresSafeArea(edges: .top)
            )
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Theme.bevelDark),
                alignment: .bottom
            )

            // Nav items
            VStack(spacing: 2) {
                ForEach(items, id: \.tab) { item in
                    SidebarItemView(
                        label: item.label,
                        icon: item.icon,
                        isSelected: sidebarVM.selectedTab == item.tab
                    ) {
                        sidebarVM.select(item.tab)
                        onClose?()
                    }
                }

                Divider()
                    .background(Theme.border)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)

                SidebarItemView(
                    label: "Import",
                    icon: "plus.square.fill",
                    isSelected: false
                ) {
                    libraryVM.isImporting = true
                    onClose?()
                }
            }
            .padding(.top, 6)

            Spacer()

            // Bottom version tag
            Text("v1.0")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(Theme.subtext.opacity(0.5))
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Theme.sidebar
                .ignoresSafeArea()
        )
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(Theme.bevelDark),
            alignment: .trailing
        )
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
                // Active bar
                Rectangle()
                    .fill(isSelected ? Theme.accent : Color.clear)
                    .frame(width: 3)

                VStack(spacing: 5) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? Theme.accent : Theme.subtext)
                    Text(label)
                        .font(.system(size: 9, weight: isSelected ? .bold : .regular))
                        .foregroundStyle(isSelected ? Theme.text : Theme.subtext)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    isSelected
                        ? Theme.accent.opacity(0.15)
                        : Color.clear
                )
            }
        }
        .buttonStyle(.plain)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Theme.border),
            alignment: .bottom
        )
    }
}

// MARK: - Preview

#Preview {
    let playerVM  = PlayerViewModel()
    let sidebarVM = SidebarViewModel()
    let libraryVM = LibraryViewModel(playerViewModel: playerVM)
    return HStack(spacing: 0) {
        SidebarView()
        Spacer()
    }
    .environmentObject(sidebarVM)
    .environmentObject(libraryVM)
    .frame(height: 500)
    .background(Theme.background)
}
