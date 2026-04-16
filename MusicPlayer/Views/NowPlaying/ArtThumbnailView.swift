import SwiftUI

struct ArtThumbnailView: View {

    @EnvironmentObject var playerVM: PlayerViewModel

    var body: some View {
        ZStack {
            if let data = playerVM.currentSong?.artworkData,
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                Theme.controlsBg
                VStack(spacing: 6) {
                    Image(systemName: "film")
                        .font(.system(size: 28))
                        .foregroundStyle(Theme.accent.opacity(0.4))
                    Image(systemName: "music.note")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.subtext.opacity(0.3))
                }
            }
        }
        .frame(width: 130)
        .insetPanel(cornerRadius: 0)
    }
}

// MARK: - Preview

#Preview("No art") {
    ArtThumbnailView()
        .environmentObject(PlayerViewModel())
        .frame(height: 200)
        .background(Theme.panel)
}

#Preview("With song") {
    let vm = PlayerViewModel()
    vm.currentSong = Song(title: "Ambience : Water", artist: "Nature Sounds", duration: 245, bookmarkData: Data())
    return ArtThumbnailView()
        .environmentObject(vm)
        .frame(height: 200)
        .background(Theme.panel)
}
