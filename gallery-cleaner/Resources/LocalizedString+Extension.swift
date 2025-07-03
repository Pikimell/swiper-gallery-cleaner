import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @AppStorage("selectedLanguage") var selectedLanguage: String = Locale.current.language.languageCode?.identifier ?? "en" {
        didSet {
            objectWillChange.send()
        }
    }

    var bundle: Bundle {
        let lang = normalizedLanguageCode
        if let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
    }

    private var normalizedLanguageCode: String {
        // Усуваємо можливі "uk_UA", "en_EN", залишаємо лише "uk", "en"
        if selectedLanguage.contains("_") {
            return selectedLanguage.components(separatedBy: "_").first ?? "en"
        }
        return selectedLanguage
    }

    func localizedString(forKey key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: bundle, comment: "")
    }
}

extension String {
    var localized: String {
        LocalizationManager.shared.localizedString(forKey: self)
    }

    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}
