import SwiftUI

struct StorageSectionView: View {
    @AppStorage("isCacheEnabled") private var isCacheEnabled: Bool = true
    @State private var cacheSize: String = "—"
    @Environment(\.theme) private var theme

    var body: some View {
        Section(header: Text("settings_storage_header".localized)) {
            Toggle(isOn: $isCacheEnabled) {
                Label("settings_cache_toggle".localized, systemImage: "internaldrive")
            }
            .toggleStyle(SwitchToggleStyle(tint: theme.accent))

            HStack {
                Label("settings_cache_size".localized, systemImage: "memorychip")
                Spacer()
                Text(cacheSize)
                    .foregroundColor(theme.textSecondary)
            }

            Button(action: {
                clearCache()
            }) {
                Label("settings_clear_cache".localized, systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            loadCacheSize()
        }
    }

    // Імітація завантаження обсягу кешу
    private func loadCacheSize() {
        // Тут має бути логіка обчислення кешу, поки — заглушка
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.cacheSize = "23.4 MB"  // тимчасове значення
        }
    }

    // Імітація очищення кешу
    private func clearCache() {
        // Очистити кеш фото або мініатюр тут
        self.cacheSize = "0 MB"
    }
}
