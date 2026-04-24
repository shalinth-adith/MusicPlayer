import Foundation
import Combine

final class ThemeManager: ObservableObject {

    private let key = "userColorScheme"

    @Published private(set) var isDark: Bool

    init() {
        isDark = UserDefaults.standard.bool(forKey: "userColorScheme")
    }

    func toggle() {
        isDark.toggle()
        UserDefaults.standard.set(isDark, forKey: key)
    }
}
