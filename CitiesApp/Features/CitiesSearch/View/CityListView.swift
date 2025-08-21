import SwiftUI

struct CityListView: View {
    @Environment(\.colorScheme) private var deviceScheme
    @Environment(\.horizontalSizeClass) private var hSize
    @EnvironmentObject private var appVM: AppViewModel

    @StateObject private var vm: CityListViewModel
    
    @State private var mapCity: City?
    @State private var infoCity: City?
    
    @ObservedObject private var favs = FavoritesStore.shared
    
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
            Text(String(localized: "error.generic")).multilineTextAlignment(.center)
            Text(message).font(.caption2).multilineTextAlignment(.center)
            Button { Task { await vm.load() } } label: {
                Text(String(localized: "action.retry"))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func ShowFavButton(_ cityId: Int) -> some View {
        Button {
            favs.toggle(id: cityId)
        } label: {
            Image(systemName: favs.contains(id: cityId) ? "star.fill" : "star")
                .foregroundStyle(favs.contains(id: cityId) ? .yellow : .secondary)
        }
        .buttonStyle(.bordered)
        .tint(.primary.opacity(0.0))
    }
    
    @ViewBuilder
    private func ShowInfoButton(_ city: City) -> some View {
        Button {
            infoCity = city
        } label: {
            Image(systemName: "info.circle")
                .foregroundStyle(Color.secondary)
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier("infoButton_\(city.id)")
    }
    
    @ViewBuilder
    private func CitiesList(selection: Binding<City?>? = nil) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(vm.filtered) { city in
                    HStack() {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("\(city.name), \(city.country)")
                                    .font(.headline)
                                
                            }
                            Text("lat: \(Text(String(format: "%.5f", city.coord.lat)))  lon: \(Text(String(format: "%.5f", city.coord.lon)))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        ShowFavButton(city.id)
                        ShowInfoButton(city)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.primary.opacity(0.05))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let selection {
                            selection.wrappedValue = city
                        } else {
                            mapCity = city
                        }
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
            GeometryReader { geo in
                let isWide = (hSize == .regular) || (geo.size.width > geo.size.height)
                if isWide {
                    HStack(spacing: 0) {
                        // Left column: search + list with selection
                        VStack(spacing: 0) {
                            if !(vm.isLoading && vm.cities.isEmpty) {
                                SearchField()
                            }
                            Group {
                                if vm.isLoading && vm.cities.isEmpty {
                                    LoadingView()
                                } else if let error = vm.error, vm.cities.isEmpty {
                                    ErrorView(error)
                                } else {
                                    CitiesList(selection: $vm.selected)
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
                        }
                        .frame(width: max(320, geo.size.width * 0.45))

                        Divider()

                        // Right column: map detail updates with selection
                        Group {
                            if let sel = vm.selected {
                                CityMapView(city: sel)
                                    .id(sel.id) // forces map to recenter on selection change
                            } else {
                                ContentUnavailableView {
                                    Label(String(localized: "CitiesApp"), systemImage: "map")
                                } description: {
                                    Text(String(localized: "select.city"))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    VStack(spacing: 0) {
                        if !(vm.isLoading && vm.cities.isEmpty) {
                            SearchField()
                        }
                        Group {
                            if vm.isLoading && vm.cities.isEmpty {
                                LoadingView()
                            } else if let error = vm.error, vm.cities.isEmpty {
                                ErrorView(error)
                            } else {
                                // In compact, tapping a cell navigates to map via mapCity binding
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
                    }
                }
            }
            .navigationTitle("")
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
            .onChange(of: vm.filtered.map(\.id)) { _, _ in
                vm.clearSelectionIfHidden()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(String(localized: "title.cities"))
                        .font(.largeTitle).bold()
                        .accessibilityIdentifier("navTitle")
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        vm.showFavorites.toggle()
                    } label: {
                        Image(systemName: vm.showFavorites ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundStyle(vm.showFavorites ? Color.yellow : Color.primary)
                            .frame(width: 32, height: 32)
                    }
                    .accessibilityIdentifier("favFilterButton")
                    .accessibilityLabel(vm.showFavorites ? String(localized: "accessibility.showAllCities") : String(localized: "accessibility.showFavoritesCities"))

                    Button { appVM.toggleTheme(deviceScheme: deviceScheme) } label: {
                        Image(systemName: appVM.iconName(deviceScheme: deviceScheme))
                            .font(.title2)
                            .foregroundStyle(Color.primary)
                            .frame(width: 32, height: 32)
                    }
                    .accessibilityLabel(appVM.accessibilityLabel(deviceScheme: deviceScheme))
                    .contextMenu {
                        Button("Follow System") { appVM.resetToSystem() }
                        Button("Light") { appVM.theme = .light }
                        Button("Dark") { appVM.theme = .dark }
                    }
                }
            }
            .preferredColorScheme(appVM.appliedScheme())
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
        .environmentObject(AppViewModel())
}
