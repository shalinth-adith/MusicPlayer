import Foundation

struct RadioBrowserStation: Decodable, Identifiable {
    let stationuuid: String
    let name: String
    let url_resolved: String
    let tags: String
    let country: String

    var id: String { stationuuid }
}

final class RadioBrowserService: @unchecked Sendable {

    func fetchStations(countryCode: String) async throws -> [RadioBrowserStation] {
        let urlString = "https://de1.api.radio-browser.info/json/stations/bycountrycodeexact/\(countryCode)?limit=20&hidebroken=true&order=votes&reverse=true"
        guard let url = URL(string: urlString) else { return [] }
        var request = URLRequest(url: url)
        request.setValue("MusicPlayerApp/1.0", forHTTPHeaderField: "User-Agent")
        let (data, _) = try await URLSession.shared.data(for: request)
        return (try? JSONDecoder().decode([RadioBrowserStation].self, from: data)) ?? []
    }
}
