//
//  ContentView.swift
//  MusicPlayer
//
//  Created by shalinth adithyan on 16/04/26.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var sidebarVM: SidebarViewModel

    var body: some View {
        HStack(spacing: 0) {
            // Left: sidebar
            SidebarView()

            // Right: main content + art thumbnail stacked over player
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Main panel
                    Group {
                        switch sidebarVM.selectedTab {
                        case .nowPlaying: NowPlayingView()
                        case .library:    LibraryView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Top-right art thumbnail
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

#Preview {
    ContentView()
        .environmentObject(SidebarViewModel())
        .environmentObject(PlayerViewModel())
        .environmentObject(LibraryViewModel(playerViewModel: PlayerViewModel()))
}
