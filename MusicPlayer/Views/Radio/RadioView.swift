import SwiftUI

struct RadioView: View {

    @EnvironmentObject var playerVM: PlayerViewModel
    @EnvironmentObject var radioVM: RadioViewModel

    var body: some View {
        List {
            // MARK: - Near You
            Section("Near You") {
                if radioVM.locationDenied {
                    Text("Enable Location in Settings to see local stations.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(.secondaryLabel))
                        .listRowBackground(Color.clear)
                } else if radioVM.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                        .listRowBackground(Color.clear)
                } else if radioVM.localStations.isEmpty && radioVM.countryCode == nil {
                    Text("Fetching your location…")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(.secondaryLabel))
                        .listRowBackground(Color.clear)
                } else if radioVM.localStations.isEmpty {
                    Text("No stations found for your region.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(.secondaryLabel))
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(radioVM.localStations) { station in
                        LocalStationRow(
                            station: station,
                            isPlaying: isPlayingLocal(station)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture { playLocal(station) }
                    }
                }
            }

            // MARK: - Curated Stations
            ForEach(RadioStation.grouped, id: \.label) { group in
                Section(group.label) {
                    ForEach(group.stations) { station in
                        RadioStationRow(station: station, isPlaying: isPlaying(station))
                            .contentShape(Rectangle())
                            .onTapGesture { play(station) }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Radio")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { radioVM.start() }
    }

    // MARK: - Curated helpers

    private func isPlaying(_ station: RadioStation) -> Bool {
        playerVM.currentSong?.assetURLString == station.streamURL && playerVM.isPlaying
    }

    private func play(_ station: RadioStation) {
        let song = Song(
            title: station.name,
            artist: station.genre,
            duration: 0,
            bookmarkData: Data(),
            assetURLString: station.streamURL
        )
        playerVM.play(song)
        playerVM.showNowPlayingSheet = true
    }

    // MARK: - Local helpers

    private func isPlayingLocal(_ station: RadioBrowserStation) -> Bool {
        playerVM.currentSong?.assetURLString == station.url_resolved && playerVM.isPlaying
    }

    private func playLocal(_ station: RadioBrowserStation) {
        let song = Song(
            title: station.name,
            artist: station.country,
            duration: 0,
            bookmarkData: Data(),
            assetURLString: station.url_resolved
        )
        playerVM.play(song)
        playerVM.showNowPlayingSheet = true
    }
}

// MARK: - Local Station Row

private struct LocalStationRow: View {
    let station: RadioBrowserStation
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Theme.accent.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Theme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(station.name)
                    .font(.system(size: 15, weight: isPlaying ? .semibold : .regular))
                    .foregroundStyle(Color(.label))
                    .lineLimit(1)
                Text(station.tags.isEmpty ? station.country : station.tags)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineLimit(1)
            }

            Spacer()

            if isPlaying {
                Image(systemName: "waveform")
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.accent)
                    .symbolEffect(.variableColor)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Curated Station Row

private struct RadioStationRow: View {
    let station: RadioStation
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Theme.accent.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Theme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(station.name)
                    .font(.system(size: 15, weight: isPlaying ? .semibold : .regular))
                    .foregroundStyle(Color(.label))
                Text(station.genre)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.secondaryLabel))
            }

            Spacer()

            if isPlaying {
                Image(systemName: "waveform")
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.accent)
                    .symbolEffect(.variableColor)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RadioView()
            .environmentObject(PlayerViewModel())
            .environmentObject(RadioViewModel())
    }
}
