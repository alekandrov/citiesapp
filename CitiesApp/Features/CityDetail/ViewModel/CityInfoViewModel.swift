import Foundation

@MainActor
final class CityInfoViewModel: ObservableObject {
    let city: City

    init(city: City) {
        self.city = city
    }

    func flagURL() -> URL? {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "FlagsURL") as? String else {
            assertionFailure("Missing FlagsURL in Info.plist")
            return nil
        }
        let code = city.country.uppercased()
        guard let url = URL(string: String(format: urlString, code)) else {
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
