import SwiftUI

struct CityListView: View {
    @StateObject private var vm: CityListViewModel
    @State private var mapCity: City?
    @State private var infoCity: City?
    
    init(service: CityServiceProtocol = CityService()) {
        _vm = StateObject(wrappedValue: CityListViewModel(service: service))
    }
    
    private func SearchField() -> some View {
        HStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
                    .frame(height: 40)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField(String(localized: "search.placeholder"), text: $vm.searchText)
                        .accessibilityIdentifier("searchField")
                }
                .padding(.horizontal, 8)
            }
            if !vm.searchText.isEmpty {
                Button(String(localized: "search.cancel")) {
                    vm.searchText = ""
                }
                .foregroundColor(.blue)
            }
        }
        .padding([.horizontal, .top])
    }
    
    @ViewBuilder
    private func LoadingView() -> some View {
        ProgressView { Text(String(localized: "loading.cities")) }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func ErrorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message).multilineTextAlignment(.center)
            Button { Task { await vm.load() } } label: {
                Text(String(localized: "action.retry"))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func CitiesList() -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(vm.filtered) { city in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(city.name), \(city.country)")
                                .font(.headline)
                            Spacer()
                            Button {
                                infoCity = city
                            } label: {
                                Image(systemName: "info.circle")
                            }
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier("infoButton_\(city.id)")
                        }
                        Text("lat: \(city.coord.lat), lon: \(city.coord.lon) • id: \(city.id)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        mapCity = city
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .ignore)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("cell_\(city.id)")
                }
            }
            .padding()
        }
    }
    
    var body: some View {
        NavigationStack {
            SearchField()
            Group {
                if vm.isLoading && vm.cities.isEmpty {
                    LoadingView()
                } else if let error = vm.error, vm.cities.isEmpty {
                    ErrorView(error)
                } else {
                    CitiesList()
                        .overlay {
                            if vm.isLoading {
                                ProgressView()
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                }
            }
            .navigationTitle(Text(String(localized: "title.cities")))
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if vm.cities.isEmpty {
                    await vm.load()
                }
            }
            .refreshable { await vm.load() }
            .navigationDestination(item: $mapCity) { city in
                CityMapView(city: city)
            }
            .navigationDestination(item: $infoCity) { city in
                CityInfoView(city: city)
            }
            .alert(Text(String(localized: "error")), isPresented: .constant(vm.error != nil), actions: {
                Button { vm.error = nil } label: { Text(String(localized: "ok")) }
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
