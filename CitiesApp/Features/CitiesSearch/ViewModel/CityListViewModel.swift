import Foundation

enum CityRoute: Identifiable, Hashable {
    case map(City)
    case info(City)

    var id: String {
        switch self {
        case .map(let c): return "map-\(c.id)"
        case .info(let c): return "info-\(c.id)"
        }
    }
}

@MainActor
final class CityListViewModel: ObservableObject {
    @Published private(set) var cities: [City] = []
    @Published var searchText: String = ""
    @Published private(set) var isLoading = false
    @Published var error: String?
    @Published var selected: City? = nil
    @Published var showFavorites: Bool = false
    @Published var route: CityRoute?

    func select(_ city: City) { selected = city }
    func clearSelectionIfHidden() {
        if let sel = selected, !filtered.contains(where: { $0.id == sel.id }) {
            selected = nil
        }
    }
    
    private let service: CityServiceProtocol
    private let favorites: FavoritesRepository
    
    private var namesNormalized: [String] = []
    
    private func normalize(_ s: String) -> String {
        s.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
    
    init(service: CityServiceProtocol = CityService(),
         favorites: FavoritesRepository = UserDefaultsFavoritesRepository()) {
        self.service = service
        self.favorites = favorites
    }
    
    var filtered: [City] {
        let q = normalize(searchText)

        let base: [City]
        if q.isEmpty {
            base = cities
        } else {
            var result: [City] = []
            result.reserveCapacity(min(cities.count, 500))
            for (i, norm) in namesNormalized.enumerated() {
                if norm.hasPrefix(q) { result.append(cities[i]) }
            }
            base = result
        }
        
        if showFavorites {
            let favIDs = favorites.allIDs()
            return base.filter { favIDs.contains($0.id) }
        } else {
            return base
        }
    }
    
    func toggleFavorite(_ id: Int) {
        favorites.toggle(id: id)
        objectWillChange.send()
    }

    func isFavorite(_ id: Int) -> Bool {
        favorites.isFavorite(id: id)
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
    
    func didTapMap(for city: City) {
        route = .map(city)
    }

    func didTapInfo(for city: City) {
        route = .info(city)
    }
}
