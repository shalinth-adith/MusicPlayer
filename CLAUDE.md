# MusicPlayer — Claude Code Instructions

## Project Overview
iOS music player app inspired by Windows Media Player 9 UI. Users can import and sync audio files from the iOS Files app. Built with SwiftUI targeting iOS 26+.

## Architecture: Strict MVVM
- **Models** (`MusicPlayer/Models/`) — pure data structs/enums, no UI imports
- **Services** (`MusicPlayer/Services/`) — pure Swift logic, no `@Published`, no SwiftUI
- **ViewModels** (`MusicPlayer/ViewModels/`) — `ObservableObject` classes, all business logic and state
- **Views** (`MusicPlayer/Views/`) — display only, zero business logic, call ViewModel methods on user actions

## Rules
- Views must never hold business logic — only `@State` for trivial local UI state (e.g. sheet toggles)
- Services are injected into ViewModels; Views never access Services directly
- All ViewModels are `@MainActor`
- Use `@EnvironmentObject` to pass ViewModels down the view hierarchy (injected at root in `MusicPlayerApp.swift`)

## Key Technologies
- `AVFoundation` — audio playback (`AVAudioPlayer`) and metadata extraction (`AVAsset`)
- `MediaPlayer` — lock screen / Control Center integration (`MPNowPlayingInfoCenter`, `MPRemoteCommandCenter`)
- SwiftUI `.fileImporter` — file picking from iOS Files app
- Security-scoped bookmarks — persistent file references across app launches

## Color Palette (WMP9 Theme)
- Background: `#1a2a4a` (deep navy)
- Sidebar: `#2d3f6b` (steel blue)
- Accent: `#4fc3f7` (bright blue)
- Seek bar fill: green
- Text: white

## File Structure
```
MusicPlayer/
├── Models/
│   ├── Song.swift
│   ├── RepeatMode.swift
│   └── AppTab.swift
├── Services/
│   ├── AudioPlayerService.swift
│   └── FileImportService.swift
├── ViewModels/
│   ├── PlayerViewModel.swift
│   ├── LibraryViewModel.swift
│   └── SidebarViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── Sidebar/SidebarView.swift
│   ├── NowPlaying/NowPlayingView.swift
│   ├── NowPlaying/ArtThumbnailView.swift
│   ├── Library/LibraryView.swift
│   ├── Library/SongRowView.swift
│   ├── Player/PlayerControlsView.swift
│   └── Player/SeekBarView.swift
└── MusicPlayerApp.swift
```

## Build Notes
- Frameworks required: `AVFoundation`, `MediaPlayer`
- Info.plist keys: `UIFileSharingEnabled`, `LSSupportsOpeningDocumentsInPlace`, `UIBackgroundModes: [audio]`
- After adding new `.swift` files, register them in `project.pbxproj`
