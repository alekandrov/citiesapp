import SwiftUI

struct CityListView: View {
    @StateObject private var vm: CityListViewModel

    init(service: CityServiceProtocol = CityService()) {
        _vm = StateObject(wrappedValue: CityListViewModel(service: service))
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.cities.isEmpty {
                    ProgressView("Cargando ciudades…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = vm.error, vm.cities.isEmpty {
                    VStack(spacing: 12) {
                        Text(error).multilineTextAlignment(.center)
                        Button("Reintentar") { Task { await vm.load() } }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(vm.filtered) { city in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(city.name) (\(city.country))")
                                .font(.headline)
                            Text("id: \(city.id)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .overlay {
                        if vm.isLoading { ProgressView().padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 12)) }
                    }
                }
            }
            .navigationTitle("Ciudades")
            .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Filtrar")
            .task { await vm.load() }
            .alert("Error", isPresented: .constant(vm.error != nil), actions: {
                Button("OK") { vm.error = nil }
            }, message: {
                Text(vm.error ?? "")
            })
        }
    }
}

struct MockCityService: CityServiceProtocol {
    func fetchCities() async throws -> [City] {
        [
            City(country: "UA", name: "Hurzuf", id: 707860, coord: .init(lon: 34.283333, lat: 44.549999)),
            City(country: "AR", name: "Buenos Aires", id: 123, coord: .init(lon: -58.3816, lat: -34.6037)),
            City(country: "US", name: "Houston", id: 456, coord: .init(lon: -95.3698, lat: 29.7604)),
        ]
    }
}

#Preview {
    CityListView(service: MockCityService())
}
