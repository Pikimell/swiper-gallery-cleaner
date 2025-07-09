import SwiftUI

struct StorageSectionView: View {
    @AppStorage("isCacheEnabled") private var isCacheEnabled: Bool = true
    @State private var cacheSize: String = "—"
    @Environment(\.theme) private var theme

    private var imageHashCacheURL: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("ImageHashes", isDirectory: true)
    }

    var body: some View {
        Section(header: Text("settings_storage_header".localized)) {
//            Toggle(isOn: $isCacheEnabled) {
//                Label("settings_cache_toggle".localized, systemImage: "internaldrive")
//            }
//            .toggleStyle(SwitchToggleStyle(tint: theme.accent))

            HStack {
                Label("settings_cache_size".localized, systemImage: "memorychip")
                Spacer()
                Text(cacheSize)
                    .foregroundColor(theme.textSecondary)
            }

            Button(role: .destructive) {
                clearCache()
            } label: {
                Label("settings_clear_cache".localized, systemImage: "trash")
            }
        }
        .onAppear {
            updateCacheSize()
        }
    }

    private func updateCacheSize() {
        guard let folder = imageHashCacheURL else {
            cacheSize = "—"
            return
        }

        let size = computeDirectorySize(folder)
        let sizeInMB = Double(size) / 1024 / 1024
        cacheSize = String(format: "%.1f MB", sizeInMB)
    }

    private func computeDirectorySize(_ folderURL: URL) -> Int {
        var size: Int = 0

        do {
            let files = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: [.fileSizeKey], options: [])
            for file in files {
                let values = try file.resourceValues(forKeys: [.fileSizeKey])
                size += values.fileSize ?? 0
            }
        } catch {
            print("Failed to compute cache size:", error.localizedDescription)
        }

        return size
    }

    private func clearCache() {
        guard let folder = imageHashCacheURL else { return }

        do {
            let files = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            for file in files {
                try FileManager.default.removeItem(at: file)
            }
        } catch {
            print("Failed to clear cache:", error.localizedDescription)
        }

        updateCacheSize()
    }
}
