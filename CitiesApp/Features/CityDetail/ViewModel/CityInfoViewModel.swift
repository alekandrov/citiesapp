import Foundation

@MainActor
final class CityInfoViewModel: ObservableObject {
    let city: City

    init(city: City) {
        self.city = city
    }

    func flagURL() -> URL? {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "FlagsURL") as? String,
              let url = URL(string: String(format: urlString,city.country)) else {
            fatalError("FlagsURL key missing or invalid in Info.plist")
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
