
import Foundation
import Photos
import SwiftUI

class TrashManager: ObservableObject {
    @Published var trashedPhotos: [PhotoItem] = []

    // Додати фото до кошика
    func addToTrash(_ photo: PhotoItem) {
        if !trashedPhotos.contains(photo) {
            trashedPhotos.append(photo)
        }
    }

    // Відновити фото (прибрати з кошика)
    func restorePhoto(_ photo: PhotoItem) {
        trashedPhotos.removeAll { $0.id == photo.id }
    }

    // Остаточне видалення фото з Photo Library
    func deleteAllFromLibrary() {
        let assetsToDelete = trashedPhotos.map { $0.asset }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.trashedPhotos.removeAll()
                } else {
                    print("❌ Не вдалося видалити фото: \(error?.localizedDescription ?? "Невідомо")")
                }
            }
        }
    }
}
