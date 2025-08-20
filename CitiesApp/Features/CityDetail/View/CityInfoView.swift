import SwiftUI

struct CityInfoView: View {
    let city: City
    
    @ViewBuilder
    private func CountryFlag() -> some View {
        HStack {
            Spacer()
            AsyncImage(url: URL(string: "https://flaglog.com/codes/standardized-rectangle-120px/\(city.country).png")) { image in
                image
                    .resizable()
                    .frame(width: 180, height: 120)
                    .scaledToFit()
                    .border(Color.gray)
            } placeholder: {
                ProgressView()
            }
            Spacer()
        }.padding(.top, 16)
    }
    
    var body: some View {
        Form {
            Section(header: CountryFlag()) {}
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
