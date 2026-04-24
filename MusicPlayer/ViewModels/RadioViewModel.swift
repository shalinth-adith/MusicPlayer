import Foundation
import Combine
import CoreLocation

@MainActor
final class RadioViewModel: ObservableObject {

    @Published private(set) var localStations: [RadioBrowserStation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var countryCode: String?
    @Published private(set) var locationDenied = false

    private let locationService = LocationService()
    private let radioService = RadioBrowserService()

    init() {
        locationService.onCountryCode = { [weak self] code in
            Task { @MainActor [weak self] in
                self?.countryCode = code
                await self?.fetchLocalStations(for: code)
            }
        }
    }

    func start() {
        guard localStations.isEmpty && !isLoading else { return }
        let status = locationService.authorizationStatus
        if status == .denied || status == .restricted {
            locationDenied = true
            return
        }
        locationService.requestLocation()
    }

    private func fetchLocalStations(for code: String) async {
        isLoading = true
        defer { isLoading = false }
        localStations = (try? await radioService.fetchStations(countryCode: code)) ?? []
    }
}
