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
            updateCacheSize()
        }
    }

    private func updateCacheSize() {
        let bytes = ImageCacheManager.shared.totalCacheSizeInBytes()
        let sizeInMB = Double(bytes) / 1024 / 1024
        self.cacheSize = String(format: "%.1f MB", sizeInMB)
    }

    private func clearCache() {
        ImageCacheManager.shared.clearCache()
        updateCacheSize()
    }
}
