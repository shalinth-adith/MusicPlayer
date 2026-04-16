import SwiftUI

enum Theme {
    // MARK: - Palette
    static let background   = Color(hex: "1a1f3c")   // deep navy
    static let panel        = Color(hex: "2a3158")    // medium blue-slate
    static let accent       = Color(hex: "4a6fa5")    // WMP blue highlight
    static let controlsBg   = Color(hex: "0d1020")    // near black
    static let text         = Color(hex: "c8d4e8")    // light blue-white
    static let buttonBg     = Color(hex: "3a4a6a")    // beveled gray-blue
    static let seekGreen    = Color(hex: "3db843")    // classic WMP green
    static let sidebar      = Color(hex: "1e2548")    // slightly lighter than bg

    // MARK: - Bevel helpers
    static let bevelLight   = Color.white.opacity(0.18)
    static let bevelDark    = Color.black.opacity(0.55)
    static let border       = Color.white.opacity(0.10)
    static let subtext      = Color(hex: "c8d4e8").opacity(0.55)
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
