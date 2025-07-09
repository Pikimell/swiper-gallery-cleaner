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
    @EnvironmentObject var storeKit: StoreKitManager

    var body: some View {
        NavigationView {
            Form {
                
                ApperanceSectionView(selectedTheme: $selectedTheme)
                LanguageSectionView(selectedLanguage: $selectedLanguage)
                //AnimationSectionView()
                //StorageSectionView()
//                SubscriptionSectionView()
                FeedbackSectionView()
                FAQSectionView()
                PolicySectionView()
                //AboutAppSectionView()
                
            }
            .navigationTitle("settings_title".localized)
        }
    }
}

#Preview {
    SettingsView()
}
