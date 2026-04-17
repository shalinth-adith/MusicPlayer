import SwiftUI

/// Scrolls text horizontally when it overflows its container, WMP9-style.
struct MarqueeText: View {
    let text: String
    var font: Font = .system(size: 11)
    var color: Color = Theme.text
    var speed: Double = 40   // points per second

    @State private var containerWidth: CGFloat = 0
    @State private var textWidth: CGFloat = 0
    @State private var offset: CGFloat = 0

    private var needsScroll: Bool { textWidth > containerWidth }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Hidden size probe
                Text(text)
                    .font(font)
                    .fixedSize()
                    .hidden()
                    .background(
                        GeometryReader { inner in
                            Color.clear
                                .onAppear {
                                    containerWidth = geo.size.width
                                    textWidth = inner.size.width
                                    if inner.size.width > geo.size.width {
                                        startScroll()
                                    }
                                }
                                .onChange(of: text) { _, _ in
                                    // Kill the in-flight repeatForever animation, then restart
                                    withAnimation(.linear(duration: 0)) { offset = 0 }
                                    textWidth = inner.size.width
                                    containerWidth = geo.size.width
                                    if inner.size.width > geo.size.width {
                                        startScroll()
                                    }
                                }
                        }
                    )

                Text(text)
                    .font(font)
                    .foregroundStyle(color)
                    .fixedSize()
                    .offset(x: offset)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear,  location: 0),
                                .init(color: .black,  location: 0.04),
                                .init(color: .black,  location: 0.96),
                                .init(color: .clear,  location: 1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .clipped()
    }

    private func startScroll() {
        guard needsScroll else { return }
        let scrollDistance = textWidth + 32
        let duration = scrollDistance / speed

        withAnimation(
            .linear(duration: duration)
            .repeatForever(autoreverses: false)
            .delay(1.5)
        ) {
            offset = -(scrollDistance)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        MarqueeText(text: "Ambience : Water — Nature Sounds • WMP Classic Edition")
            .frame(width: 200, height: 18)
        MarqueeText(text: "Short")
            .frame(width: 200, height: 18)
    }
    .padding()
    .background(Theme.controlsBg)
}
