import Foundation
import Photos
import SwiftUI

class TrashManager: ObservableObject {
    
    @Published var trashedPhotos: [PhotoItem] = []

    // MARK: - UserDefaults Keys
    private let deletedBytesKey = "deletedPhotoBytes"
    private let deletedCountKey = "deletedPhotoCount"

    // MARK: - Додати фото до кошика
    func addToTrash(_ photo: PhotoItem) {
        if !trashedPhotos.contains(photo) {
            trashedPhotos.append(photo)
        }
    }

    // MARK: - Відновити фото
    func restorePhoto(_ photo: PhotoItem) {
        trashedPhotos.removeAll { $0.id == photo.id }
    }

    // MARK: - Видалити всі з бібліотеки та рахувати розмір і кількість
    func deleteAllFromLibrary(viewModel: PhotoLibraryViewModel) {
        let assetsToDelete = trashedPhotos.map { $0.asset }

        var totalDeletedBytes: Int64 = 0
        let dispatchGroup = DispatchGroup()

        for asset in assetsToDelete {
            dispatchGroup.enter()

            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.isNetworkAccessAllowed = false
            options.deliveryMode = .highQualityFormat

            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                if let data = data {
                    totalDeletedBytes += Int64(data.count)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        print("✅ Фото успішно видалені")
                        let deletedCount = self.trashedPhotos.count
                        self.trashedPhotos.removeAll()
                        viewModel.fetchPhotos()

                        // Збереження в UserDefaults
                        let oldBytes = UserDefaults.standard.integer(forKey: self.deletedBytesKey)
                        let newBytes = oldBytes + Int(totalDeletedBytes)
                        UserDefaults.standard.set(newBytes, forKey: self.deletedBytesKey)

                        let oldCount = UserDefaults.standard.integer(forKey: self.deletedCountKey)
                        let newCount = oldCount + deletedCount
                        UserDefaults.standard.set(newCount, forKey: self.deletedCountKey)

                        print("🧹 Звільнено: \(Self.formatBytes(Int64(newBytes)))")
                        print("📸 Видалено фото: \(newCount)")
                    } else {
                        print("❌ Помилка при видаленні: \(error?.localizedDescription ?? "Невідомо")")
                    }
                }
            }
        }
    }

    // MARK: - Форматування байтів
    static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    // MARK: - Публічний доступ до статистики
    static func getTotalDeletedSizeFormatted() -> String {
        let bytes = UserDefaults.standard.integer(forKey: "deletedPhotoBytes")
        return formatBytes(Int64(bytes))
    }

    static func getTotalDeletedCount() -> Int {
        UserDefaults.standard.integer(forKey: "deletedPhotoCount")
    }

    // MARK: - Скидання
    static func resetStats() {
        UserDefaults.standard.set(0, forKey: "deletedPhotoBytes")
        UserDefaults.standard.set(0, forKey: "deletedPhotoCount")
    }
}
