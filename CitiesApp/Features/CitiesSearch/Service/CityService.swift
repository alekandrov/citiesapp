import Foundation

protocol CityServiceProtocol {
    func fetchCities() async throws -> [City]
}

final class CityService: CityServiceProtocol {
    private let session: URLSession
    private let url: URL

    init(session: URLSession = .shared) {
        self.session = session
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "CitiesURL") as? String,
              let url = URL(string: urlString) else {
            fatalError("CitiesURL key missing or invalid in Info.plist")
        }
        self.url = url
    }

    func fetchCities() async throws -> [City] {
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([City].self, from: data)
    }
}
