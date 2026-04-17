import SwiftUI

// MARK: - Rectangular bevel (top-bar, sidebar buttons)

struct BeveledButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 5

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(configuration.isPressed ? Theme.buttonBg.opacity(0.7) : Theme.buttonBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Theme.bevelDark, lineWidth: 1.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius - 1)
                    .stroke(Theme.bevelLight, lineWidth: 1)
                    .padding(1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

// MARK: - Dark circular (secondary transport buttons)

struct DarkCircularButtonStyle: ButtonStyle {
    var diameter: CGFloat = 40

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: diameter, height: diameter)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.buttonBg,
                                Theme.controlsBg
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            // Glass highlight on top half
            .overlay(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            )
            .overlay(Circle().stroke(Theme.bevelDark, lineWidth: 1.5))
            .overlay(
                Circle()
                    .stroke(Theme.bevelLight, lineWidth: 0.8)
                    .padding(1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

// MARK: - Bright circular (primary play/pause button)

struct CircularBevelButtonStyle: ButtonStyle {
    var diameter: CGFloat = 56

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: diameter, height: diameter)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.accent.opacity(0.9),
                                Theme.accent,
                                Theme.panel
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            // Glass gloss on top portion
            .overlay(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.25), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            )
            .overlay(Circle().stroke(Theme.bevelDark, lineWidth: 2))
            .overlay(
                Circle()
                    .stroke(Theme.bevelLight, lineWidth: 1)
                    .padding(2)
            )
            .shadow(color: Theme.accent.opacity(0.4), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}
