import SwiftUI
import MapKit

struct CityDetailView: View {
    let city: City

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: city.coord.lat, longitude: city.coord.lon)
    }

    var body: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        ))) {
            Marker(city.name, coordinate: coordinate)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle(city.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CityDetailView(city: City(country: "AR", name: "Buenos Aires", id: 123, coord: .init(lon: -58.3816, lat: -34.6037)))
}
