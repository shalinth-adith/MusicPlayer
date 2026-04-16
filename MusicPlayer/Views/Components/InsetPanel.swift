import SwiftUI

/// Applies the WMP9-style sunken inset panel border (multiple layered strokes).
struct InsetPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = 6

    func body(content: Content) -> some View {
        content
            .background(Theme.controlsBg)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            // Outermost dark border — gives the "pressed in" look
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Theme.bevelDark, lineWidth: 2)
            )
            // Inner subtle highlight
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius - 1)
                    .stroke(Theme.bevelLight, lineWidth: 1)
                    .padding(2)
            )
    }
}

extension View {
    func insetPanel(cornerRadius: CGFloat = 6) -> some View {
        modifier(InsetPanelModifier(cornerRadius: cornerRadius))
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 6)
        .fill(Color.blue.opacity(0.3))
        .frame(width: 200, height: 150)
        .insetPanel()
        .padding()
        .background(Theme.panel)
}
