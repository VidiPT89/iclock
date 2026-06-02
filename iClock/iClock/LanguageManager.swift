import Foundation
import Combine

enum AppLanguage: String, CaseIterable {
    case portuguese = "pt"
    case english    = "en"

    var localeId: String {
        switch self {
        case .portuguese: return "pt_PT"
        case .english:    return "en_GB"
        }
    }
    var displayName: String {
        switch self {
        case .portuguese: return "Português"
        case .english:    return "English"
        }
    }
    var flag: String {
        switch self {
        case .portuguese: return "🇵🇹"
        case .english:    return "🇬🇧"
        }
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var language: AppLanguage

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "pt"
        language = AppLanguage(rawValue: saved) ?? .portuguese
    }

    func setLanguage(_ lang: AppLanguage) {
        language = lang
        UserDefaults.standard.set(lang.rawValue, forKey: "appLanguage")
    }
}
