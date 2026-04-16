import SwiftUI

/// Simulates the classic WMP9 raised/beveled button look using layered strokes.
struct BeveledButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 5

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        configuration.isPressed
                            ? Theme.buttonBg.opacity(0.7)
                            : Theme.buttonBg
                    )
            )
            // Outer dark shadow border (bottom-right feel)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Theme.bevelDark, lineWidth: 1.5)
            )
            // Inner highlight border (top-left feel)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius - 1)
                    .stroke(Theme.bevelLight, lineWidth: 1)
                    .padding(1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

/// A large circular bevel for the main play/pause button.
struct CircularBevelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Circle()
                    .fill(
                        configuration.isPressed
                            ? Theme.accent.opacity(0.7)
                            : Theme.accent
                    )
            )
            .overlay(Circle().stroke(Theme.bevelDark, lineWidth: 2))
            .overlay(
                Circle()
                    .stroke(Theme.bevelLight, lineWidth: 1)
                    .padding(2)
            )
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}
