import Foundation

protocol CityServiceProtocol {
    func fetchCities() async throws -> [City]
}

final class CityService: CityServiceProtocol {
    private let session: URLSession
    private let url: URL

    init(session: URLSession = .shared,
         url: URL = URL(string: "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json")!) {
        self.session = session
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
