import Foundation

struct City: Codable, Hashable, Identifiable {
    let country: String
    let name: String
    let id: Int
    let coord: Coord

    enum CodingKeys: String, CodingKey {
        case country
        case name
        case id = "_id"
        case coord
    }
}

struct Coord: Codable, Hashable {
    let lon: Double
    let lat: Double
}
