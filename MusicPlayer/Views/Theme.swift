import SwiftUI

enum Theme {
    static let background        = Color(.systemBackground)
    static let secondaryBg       = Color(.secondarySystemBackground)
    static let text              = Color(.label)
    static let subtext           = Color(.secondaryLabel)
    static let accent            = Color(hex: "FF2D55")
    static let pillSelected      = Color(.label)
    static let pillUnselected    = Color(.systemFill)
    static let cardGradientStart = Color(hex: "C850C0")
    static let cardGradientEnd   = Color(hex: "FFAB40")
    static let seekFill          = Color(hex: "FF2D55")
}

// MARK: - Hex color init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
