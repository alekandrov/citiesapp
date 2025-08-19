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
                    ProgressView(String(localized: "loading.cities"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = vm.error, vm.cities.isEmpty {
                    VStack(spacing: 12) {
                        Text(error).multilineTextAlignment(.center)
                        Button(String(localized: "action.retry")) { Task { await vm.load() } }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(vm.filtered) { city in
                        NavigationLink {
                            CityDetailView(city: city)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(city.name) (\(city.country))")
                                    .font(.headline)
                                Text("id: \(city.id)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .overlay {
                        if vm.isLoading { ProgressView().padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 12)) }
                    }
                }
            }
            .navigationTitle(String(localized: "title.cities"))
            .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: String(localized: "search.placeholder"))
            .task { await vm.load() }
            .alert(String(localized: "error"), isPresented: .constant(vm.error != nil), actions: {
                Button(String(localized: "ok")) { vm.error = nil }
            }, message: {
                Text(vm.error ?? "")
            })
        }
    }
}

struct MockCityService: CityServiceProtocol {
    func fetchCities() async throws -> [City] {
        [
            City(country: "US", name: "Alabama", id: 4829764, coord: .init(lon: -86.750259, lat: 32.750408)),
            City(country: "US", name: "Albuquerque", id: 5454711, coord: .init(lon: -106.651138, lat: 35.084492)),
            City(country: "US", name: "Anaheim", id: 5323810, coord: .init(lon: -117.914497, lat: 33.835289)),
            City(country: "US", name: "Arizona", id: 5551752, coord: .init(lon: -111.500977, lat: 34.500301)),
            City(country: "AU", name: "Sydney", id: 2147714, coord: .init(lon: 151.207321, lat: -33.867851)),
        ]
    }
}

#Preview {
    CityListView(service: MockCityService())
}
