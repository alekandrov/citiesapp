import Foundation

@MainActor
final class CityListViewModel: ObservableObject {
    @Published private(set) var cities: [City] = []
    @Published var searchText: String = ""
    @Published private(set) var isLoading = false
    @Published var error: String?
    
    private let service: CityServiceProtocol
    
    private var namesNormalized: [String] = []
    
    private func normalize(_ s: String) -> String {
        s.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
    
    init(service: CityServiceProtocol = CityService()) {
        self.service = service
    }
    
    var filtered: [City] {
        let q = normalize(searchText)
        guard !q.isEmpty else { return cities }
        var result: [City] = []
        result.reserveCapacity(min(cities.count, 500))
        for (i, norm) in namesNormalized.enumerated() {
            if norm.hasPrefix(q) {
                result.append(cities[i])
            }
        }
        return result
    }
    
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        cities = []
        do {
            cities = try await service.fetchCities().sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            namesNormalized = cities.map { normalize($0.name) }
        } catch {
            self.error = "\(error.localizedDescription)"
        }
        isLoading = false
    }
}
