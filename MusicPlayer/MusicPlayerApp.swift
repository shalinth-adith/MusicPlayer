//
//  MusicPlayerApp.swift
//  MusicPlayer
//
//  Created by shalinth adithyan on 16/04/26.
//

import SwiftUI

@main
struct MusicPlayerApp: App {

    @StateObject private var playerVM:  PlayerViewModel
    @StateObject private var sidebarVM: SidebarViewModel
    @StateObject private var libraryVM: LibraryViewModel

    init() {
        let player = PlayerViewModel()
        _playerVM  = StateObject(wrappedValue: player)
        _libraryVM = StateObject(wrappedValue: LibraryViewModel(playerViewModel: player))
        _sidebarVM = StateObject(wrappedValue: SidebarViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playerVM)
                .environmentObject(libraryVM)
                .environmentObject(sidebarVM)
        }
    }
}
