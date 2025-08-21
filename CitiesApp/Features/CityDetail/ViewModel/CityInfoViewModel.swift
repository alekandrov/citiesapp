import Foundation

@MainActor
final class CityInfoViewModel: ObservableObject {
    let city: City

    init(city: City) {
        self.city = city
    }

    func flagURL() -> URL? {
        let code = city.country.uppercased()
        let urlString = String(format: AppConfig.flagsURLTemplate, code)
        guard let url = URL(string: urlString) else {
            assertionFailure("Invalid FlagsURL template or produced URL: \(urlString)")
            return nil
        }
        return url
    }

    func countryName() -> String {
        let locale = Locale.current
        return locale.localizedString(forRegionCode: city.country) ?? ""
    }
    
    func currencyName() -> String {
        let deviceLocale = Locale.current
        let regionLocale = Locale(identifier: "en_\(city.country)")
        if let code = regionLocale.currency?.identifier {
            return deviceLocale.localizedString(forCurrencyCode: code)?.capitalized ?? code.uppercased()
        }
        return ""
    }
}
