import Foundation

protocol CityServiceProtocol {
    func fetchCities() async throws -> [City]
}

final class CityService: CityServiceProtocol {
    private let session: URLSession
    private let url: URL

    init(session: URLSession = .shared) {
        self.url = AppConfig.citiesURL
        self.session = session
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
