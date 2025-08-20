import SwiftUI
import MapKit

struct CityMapView: View {
    let city: City
    @State private var position: MapCameraPosition
    
    init(city: City) {
        self.city = city
        let coord = CLLocationCoordinate2D(latitude: city.coord.lat, longitude: city.coord.lon)
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )))
    }
    
    var body: some View {
        Map(position: $position) {
            Marker(city.name, coordinate: CLLocationCoordinate2D(
                latitude: city.coord.lat,
                longitude: city.coord.lon
            ))
        }
        .id(city.id)
        .ignoresSafeArea()
        .navigationTitle(city.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: city.id) { _, _ in recenter() }
        .onChange(of: city.coord.lat) { _, _ in recenter() }
        .onChange(of: city.coord.lon) { _, _ in recenter() }
        .accessibilityIdentifier("cityMap")
    }
    
    private func recenter() {
        let coord = CLLocationCoordinate2D(latitude: city.coord.lat, longitude: city.coord.lon)
        withAnimation(.easeInOut(duration: 0.25)) {
            position = .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            ))
        }
    }
}

#Preview {
    CityMapView(city: City(country: "AR", name: "Buenos Aires", id: 3435910, coord: .init(lon: -58.377232, lat: -34.613152)))
}
