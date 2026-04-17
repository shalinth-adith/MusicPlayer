import SwiftUI

struct SeekBarView: View {

    @EnvironmentObject var playerVM: PlayerViewModel
    @State private var isDragging = false
    @State private var dragProgress: CGFloat = 0

    private var progress: CGFloat {
        guard playerVM.duration > 0 else { return 0 }
        let t = isDragging ? dragProgress : CGFloat(playerVM.currentTime / playerVM.duration)
        return min(max(t, 0), 1)
    }

    var body: some View {
        VStack(spacing: 6) {
            // Time labels + groove track
            HStack(alignment: .center, spacing: 10) {
                Text(formatTime(isDragging
                    ? dragProgress * playerVM.duration
                    : playerVM.currentTime))
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(Theme.subtext)
                    .frame(width: 34, alignment: .leading)

                grooveTrack

                Text(formatTime(playerVM.duration))
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(Theme.subtext)
                    .frame(width: 34, alignment: .trailing)
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 6)
    }

    // MARK: - Groove Track

    private var grooveTrack: some View {
        GeometryReader { geo in
            let width = geo.size.width

            ZStack(alignment: .leading) {
                // Track groove
                Capsule()
                    .fill(Theme.controlsBg)
                    .frame(height: 3)
                    .overlay(
                        Capsule()
                            .stroke(Color.black.opacity(0.5), lineWidth: 1)
                    )

                // Filled portion
                Capsule()
                    .fill(Theme.seekGreen)
                    .frame(width: max(0, progress * width), height: 3)

                // Thumb dot
                Circle()
                    .fill(Theme.accent)
                    .frame(width: isDragging ? 13 : 10, height: isDragging ? 13 : 10)
                    .shadow(color: Theme.accent.opacity(0.6), radius: isDragging ? 5 : 3)
                    .offset(x: max(0, progress * width - (isDragging ? 6.5 : 5)))
                    .animation(.easeOut(duration: 0.1), value: isDragging)
            }
            .frame(height: 20)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        dragProgress = min(max(value.location.x / width, 0), 1)
                    }
                    .onEnded { value in
                        let p = min(max(value.location.x / width, 0), 1)
                        playerVM.seek(to: p * playerVM.duration)
                        isDragging = false
                    }
            )
        }
        .frame(height: 20)
    }

    // MARK: - Helpers

    private func formatTime(_ time: TimeInterval) -> String {
        let t = max(0, time)
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Preview

#Preview {
    let vm = PlayerViewModel()
    vm.duration = 245
    vm.currentTime = 80
    return SeekBarView()
        .environmentObject(vm)
        .frame(width: 350)
        .background(Theme.controlsBg)
}
