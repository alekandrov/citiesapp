import SwiftUI

struct CityInfoView: View {
    let city: City
    var body: some View {
        Form {
            Section(header: Text(String(localized: "city"))) {
                HStack { Text(String(localized: "name")); Spacer(); Text(city.name) }
                HStack { Text(String(localized: "country")); Spacer(); Text(city.country) }
                HStack { Text("ID"); Spacer(); Text("\(city.id)") }
            }
            Section(header: Text(String(localized: "coordinates"))) {
                HStack { Text("Lat"); Spacer(); Text(String(format: "%.5f", city.coord.lat)) }
                HStack { Text("Lon"); Spacer(); Text(String(format: "%.5f", city.coord.lon)) }
                CityMapView(city: city)
                    .frame(height: 300)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("CityInfoView") {
    CityInfoView(city: City(country: "AR", name: "Buenos Aires", id: 3435910, coord: .init(lon: -58.377232, lat: -34.613152)))
}
