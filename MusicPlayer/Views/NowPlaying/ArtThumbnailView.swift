import SwiftUI

struct ArtThumbnailView: View {

    @EnvironmentObject var playerVM: PlayerViewModel

    var body: some View {
        ZStack {
            Theme.sidebar

            if let data = playerVM.currentSong?.artworkData,
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                VStack(spacing: 6) {
                    Image(systemName: "film")
                        .font(.system(size: 32))
                        .foregroundStyle(Theme.subtext)
                    Image(systemName: "music.note")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.subtext.opacity(0.5))
                }
            }
        }
        .frame(width: 130)
        .overlay(
            Rectangle()
                .stroke(Theme.border, lineWidth: 1)
        )
    }
}
