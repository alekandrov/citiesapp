import SwiftUI

struct CityInfoView: View {
    @EnvironmentObject var vmList: CityListViewModel
    @StateObject private var vm: CityInfoViewModel
    
    init(city: City) {
        _vm = StateObject(wrappedValue: CityInfoViewModel(city: city))
    }

    
    @ViewBuilder
    private func CountryFlag() -> some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                Spacer()
                if let url = vm.flagURL() {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .border(Color.gray)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 180, height: 120)
                } else {
                    Image(systemName: "flag.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 48)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            favoriteButton()
        }
    }
    
    @ViewBuilder
    private func favoriteButton() -> some View {
        Button {
            vmList.toggleFavorite(vm.city.id)
        } label: {
            Image(systemName: vmList.isFavorite(vm.city.id) ? "star.fill" : "star")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(vmList.isFavorite(vm.city.id) ? .yellow : .secondary)
        }
    }
    
    var body: some View {
        Form {
            Section(header: CountryFlag()) {}
            Section(header: Text(String(localized: "city"))) {
                HStack { Text(String(localized: "name")); Spacer(); Text(vm.city.name) }
                HStack { Text(String(localized: "country.name")); Spacer(); Text(vm.countryName()); Text(vm.city.country) }
                HStack { Text(String(localized: "country.currency")); Spacer(); Text(vm.currencyName()) }
                HStack { Text("ID"); Spacer(); Text(String(format: "%d", vm.city.id)) }
            }
            Section(header: Text(String(localized: "coordinates"))) {
                HStack { Text("Lat"); Spacer(); Text(String(format: "%.5f", vm.city.coord.lat)) }
                HStack { Text("Lon"); Spacer(); Text(String(format: "%.5f", vm.city.coord.lon)) }
                CityMapView(city: vm.city)
                    .frame(height: 300)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("CityInfoView") {
    CityInfoView(city: City(country: "AR", name: "Buenos Aires", id: 3435910, coord: .init(lon: -58.377232, lat: -34.613152)))
        .environmentObject(
            CityListViewModel(
                service: MockCityService(),
                favorites: UserDefaultsFavoritesRepository()
            )
        )
}
