
import Foundation
// MARK: - перечесление с темами приложения
enum Theme: Int {
    case light, dark, system
}

class SettingsViewModel {
    
    var selectedTheme: Theme = .system {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: LocalConstants.selectedThemeKey) // сохраняем в UD
        }
    }
    // MARK: отслеживает выбранную тему приложения
    func selectTheme(index: Int) {
        switch index {
        case 0:
            selectedTheme = .light
        case 1:
            selectedTheme = .dark
        case 2:
            selectedTheme = .system
        default:
            break
        }
    }
}
// MARK: - Local constantnts
extension SettingsViewModel {
    enum LocalConstants {
        static let selectedThemeKey = "selectedThemeKey"
    }
}
