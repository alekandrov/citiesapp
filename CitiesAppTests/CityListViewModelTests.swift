import XCTest
@testable import CitiesApp

private final class MockCityService: CityServiceProtocol {
    let cities: [City]

    init() {
        self.cities = [
            City(country: "ES", name: "Málaga", id: 6359472, coord: .init(lon: -4.39717, lat: 36.758541)),
            City(country: "AR", name: "Buenos Aires", id: 3435910, coord: .init(lon: -58.377232, lat: -34.613152)),
            City(country: "US", name: "Denver", id: 4463523, coord: .init(lon: -81.0298, lat: 35.53125)),
            City(country: "AU", name: "Sydney", id: 2147714, coord: .init(lon: 151.207321, lat: -33.867851)),
            City(country: "JP", name: "Sapporo-shi", id: 2128295, coord: .init(lon: 141.346939, lat: 43.064171)),
        ]
    }

    func fetchCities() async throws -> [City] { cities }
}

@MainActor
final class CityListViewModelTests: XCTestCase {

    private func makeVM() -> CityListViewModel {
        CityListViewModel(service: MockCityService())
    }

    private func load(_ vm: CityListViewModel) async {
        await vm.load()
    }

    func testNoFilterReturnsAllSorted() async {
        let vm = makeVM()
        await load(vm)

        vm.searchText = ""
        // print(vm.filtered)
        let names = vm.filtered.map { $0.name }
        XCTAssertEqual(names, ["Buenos Aires", "Denver", "Málaga", "Sapporo-shi", "Sydney"],
                       "No están ordenados correctamente")
    }

    func testDiacriticInsensitivePrefix() async {
        let vm = makeVM()
        await load(vm)

        vm.searchText = "mal"
        let names = vm.filtered.map(\.name)
        XCTAssertEqual(names, ["Málaga"], "La búsqueda debe ignorar tíldes.")
    }

    func testNoMatchesReturnsEmpty() async {
        let vm = makeVM()
        await load(vm)

        vm.searchText = "zzz"
        XCTAssertTrue(vm.filtered.isEmpty, "Si no hay coincidencias, el resultado debe ser vacío.")
    }

    func testEmptySpaces() async {
        let vm = makeVM()
        await load(vm)

        vm.searchText = "   "
        XCTAssertTrue(vm.filtered.isEmpty, "Con espacios solamente, listado vácio.")
    }

    func testSymbolsShouldReturnEmpty() async {
        let vm = makeVM()
        await load(vm)

        vm.searchText = "###"
        XCTAssertTrue(vm.filtered.isEmpty, "Símbolos que no matchean deben devolver lista vacía.")
    }

    func testUpdatesOnInputs() async {
        let vm = makeVM()
        await load(vm)

        vm.searchText = "s"
        XCTAssertEqual(vm.filtered.map(\.name), ["Sapporo-shi", "Sydney"])

        vm.searchText = "sy"
        XCTAssertEqual(vm.filtered.map(\.name), ["Sydney"])

        vm.searchText = "syd"
        XCTAssertEqual(vm.filtered.map(\.name), ["Sydney"], "")

        vm.searchText = "sydq"
        XCTAssertTrue(vm.filtered.isEmpty, "En la que no coincida deberia devolver lista vacía.")
    }

    func testDenverBeforeSydney() async {
        let vm = makeVM()
        await load(vm)
        vm.searchText = ""

        let names = vm.filtered.map(\.name)
        let denverIndex = names.firstIndex(of: "Denver")
        let sydneyIndex = names.firstIndex(of: "Sydney")

        XCTAssertNotNil(denverIndex)
        XCTAssertNotNil(sydneyIndex)
        XCTAssertLessThan(denverIndex!, sydneyIndex!,
                          "\"Denver, US\" debe aparecer antes que \"Sydney, Australia\" al ordenar por ciudad.")
    }
}
