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
        if let path = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
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
