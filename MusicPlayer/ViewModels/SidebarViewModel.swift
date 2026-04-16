import Foundation
import Combine

@MainActor
final class SidebarViewModel: ObservableObject {

    @Published var selectedTab: AppTab = .nowPlaying

    func select(_ tab: AppTab) {
        selectedTab = tab
    }
}
