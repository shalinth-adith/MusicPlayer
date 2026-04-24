import Foundation
import Combine

@MainActor
final class SidebarViewModel: ObservableObject {

    @Published var selectedTab: AppTab = .artists

    func select(_ tab: AppTab) {
        selectedTab = tab
    }
}
