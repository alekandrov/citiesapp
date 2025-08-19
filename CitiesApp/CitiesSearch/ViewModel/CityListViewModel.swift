import Foundation

@MainActor
final class CityListViewModel: ObservableObject {
    @Published private(set) var cities: [City] = []
    @Published var searchText: String = ""
    @Published private(set) var isLoading = false
    @Published var error: String?

    private let service: CityServiceProtocol

    init(service: CityServiceProtocol = CityService()) {
        self.service = service
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        do {
            cities = try await service.fetchCities()
        } catch {
            self.error = "No se pudieron cargar las ciudades. \(error.localizedDescription)"
        }
        isLoading = false
    }
}
