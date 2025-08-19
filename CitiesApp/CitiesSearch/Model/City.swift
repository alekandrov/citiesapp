import Foundation

struct City: Codable, Identifiable {
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

struct Coord: Codable {
    let lon: Double
    let lat: Double
}
