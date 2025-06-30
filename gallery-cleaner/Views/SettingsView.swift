import SwiftUI

enum AppThemeMode: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { self.rawValue }

    var localizedTitle: String {
        switch self {
        case .system: return "theme_system".localized
        case .light: return "theme_light".localized
        case .dark: return "theme_dark".localized
        }
    }
}

struct SettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme: AppThemeMode = .system
    @AppStorage("selectedLanguage") private var selectedLanguage: String = Locale.current.identifier
    @ObservedObject var localization = LocalizationManager.shared

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("settings_appearance".localized)) {
                    Picker("settings_theme".localized, selection: $selectedTheme) {
                        ForEach(AppThemeMode.allCases) { mode in
                            Text(mode.localizedTitle).tag(mode)
                        }
                    }
                }

                Section(header: Text("settings_language".localized)) {
                    Picker("settings_language".localized, selection: $selectedLanguage) {
                        Text("English").tag("en")
                        Text("Українська").tag("uk")
                    }
                }

                Section(header: Text("settings_policy".localized)) {
                    Button("settings_privacy_policy".localized) {
                        // Insert privacy policy URL here
                    }
                    Button("settings_terms_of_service".localized) {
                        // Insert terms of service URL here
                    }
                }
            }
            .navigationTitle("settings_title".localized)
        }
    }
}

#Preview {
    SettingsView()
}
