import SwiftUI

struct SidebarView: View {

    @EnvironmentObject var sidebarVM: SidebarViewModel
    @EnvironmentObject var libraryVM: LibraryViewModel
    var onClose: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header
            header

            // MARK: - Nav Items
            VStack(spacing: 2) {
                navItem(
                    label: "NOW PLAYING",
                    icon: "play.circle.fill",
                    isSelected: sidebarVM.selectedTab == .nowPlaying
                ) {
                    sidebarVM.select(.nowPlaying)
                    onClose?()
                }

                navItem(
                    label: "LIBRARY",
                    icon: "music.note.list",
                    isSelected: sidebarVM.selectedTab == .library
                ) {
                    sidebarVM.select(.library)
                    onClose?()
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 10)

            // MARK: - Divider
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

            // MARK: - Actions
            VStack(spacing: 2) {
                actionItem(label: "IMPORT", icon: "plus.square.fill") {
                    libraryVM.isImporting = true
                    onClose?()
                }

                actionItem(
                    label: libraryVM.hasMusicFolder ? "SYNC FOLDER" : "SET FOLDER",
                    icon: libraryVM.hasMusicFolder ? "arrow.triangle.2.circlepath" : "folder.badge.plus"
                ) {
                    libraryVM.isFolderPickerPresented = true
                    onClose?()
                }
            }
            .padding(.horizontal, 10)

            Spacer()

            // MARK: - Footer
            Text("WMP9 · v1.0")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(Theme.subtext.opacity(0.4))
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.sidebar.ignoresSafeArea())
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(Theme.bevelDark),
            alignment: .trailing
        )
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Image(systemName: "music.note")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.accent)
                Text("MEDIA")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.text)
            }
            Text("GUIDE")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.subtext)
                .padding(.leading, 2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.controlsBg.ignoresSafeArea(edges: .top))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Theme.bevelDark),
            alignment: .bottom
        )
    }

    // MARK: - Nav Item (tab navigation)

    @ViewBuilder
    private func navItem(
        label: String,
        icon: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : Theme.subtext)
                    .frame(width: 20)

                Text(label)
                    .font(.system(size: 11, weight: isSelected ? .bold : .regular, design: .monospaced))
                    .foregroundStyle(isSelected ? .white : Theme.subtext)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                isSelected
                    ? RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.accent)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.15), Color.clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                        )
                    : nil
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Action Item (import / folder)

    @ViewBuilder
    private func actionItem(
        label: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.subtext)
                    .frame(width: 20)

                Text(label)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Theme.subtext)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    let playerVM  = PlayerViewModel()
    let sidebarVM = SidebarViewModel()
    let libraryVM = LibraryViewModel(playerViewModel: playerVM)
    return HStack(spacing: 0) {
        SidebarView()
            .frame(width: 180)
        Spacer()
    }
    .environmentObject(sidebarVM)
    .environmentObject(libraryVM)
    .environmentObject(playerVM)
    .frame(height: 600)
    .background(Theme.background)
}
