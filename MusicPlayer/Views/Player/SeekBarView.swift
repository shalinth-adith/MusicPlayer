import SwiftUI

struct SeekBarView: View {

    @EnvironmentObject var playerVM: PlayerViewModel
    @State private var isDragging = false
    @State private var dragValue: TimeInterval = 0

    private var displayTime: TimeInterval {
        isDragging ? dragValue : playerVM.currentTime
    }

    var body: some View {
        VStack(spacing: 2) {
            Slider(
                value: Binding(
                    get: { isDragging ? dragValue : playerVM.currentTime },
                    set: { dragValue = $0 }
                ),
                in: 0...max(playerVM.duration, 1),
                onEditingChanged: { editing in
                    isDragging = editing
                    if !editing {
                        playerVM.seek(to: dragValue)
                    }
                }
            )
            .tint(Theme.seekGreen)
            .padding(.horizontal, 8)

            HStack {
                Text(formatTime(displayTime))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Theme.subtext)
                Spacer()
                Text("-\(formatTime(max(playerVM.duration - displayTime, 0)))")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Theme.subtext)
            }
            .padding(.horizontal, 12)
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let t = max(0, time)
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}
