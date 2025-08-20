import SwiftUI

final class AppViewModel: ObservableObject {
    enum ThemePreference: String, CaseIterable { case system, light, dark }
    
    @AppStorage("themePreference") private var themeRaw: String = ThemePreference.system.rawValue
    
    var theme: ThemePreference {
        get { ThemePreference(rawValue: themeRaw) ?? .system }
        set { themeRaw = newValue.rawValue; objectWillChange.send() }
    }
    
    func appliedScheme() -> ColorScheme? {
        switch theme {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
    
    func toggleTheme(deviceScheme: ColorScheme) {
        if theme == .system {
            theme = (deviceScheme == .dark) ? .light : .dark
        } else {
            theme = (theme == .dark) ? .light : .dark
        }
    }
    
    func resetToSystem() { theme = .system }
    
    func iconName(deviceScheme: ColorScheme) -> String {
        let effective: ColorScheme = (theme == .system) ? deviceScheme : (theme == .dark ? .dark : .light)
        return effective == .dark ? "moon.fill" : "sun.max.fill"
    }
    
    func accessibilityLabel(deviceScheme: ColorScheme) -> String {
        if theme == .system {
            return deviceScheme == .dark ? "Switch to light mode" : "Switch to dark mode"
        } else {
            return theme == .dark ? "Switch to light mode" : "Switch to dark mode"
        }
    }
}
