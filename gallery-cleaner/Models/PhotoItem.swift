import Foundation
import Photos
import SwiftUI

struct PhotoItem: Identifiable, Hashable {
    let id: String            // Унікальний ідентифікатор (PHAsset.localIdentifier)
    let asset: PHAsset        // Системний об'єкт, що представляє фото
    let creationDate: Date?   // Дата створення фото
    let isFavorite: Bool

    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.creationDate = asset.creationDate
        self.isFavorite = asset.isFavorite
    }

    /// Отримати мініатюру фото (для гріда)
    func thumbnail(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true

        PHImageManager.default().requestImage(
            for: self.asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            completion(image)
        }
    }

    /// Отримати повнорозмірне зображення (для фулскріну)
    func fullSizeImage(completion: @escaping (UIImage?) -> Void) {
        print("Запит на повнорозмірне зображення для \(id)")
        
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
        options.isNetworkAccessAllowed = true // обов’язково для iCloud

        imageManager.requestImage(for: asset,
                                   targetSize: PHImageManagerMaximumSize,
                                   contentMode: .aspectFit,
                                   options: options) { image, info in
            if let info = info {
                print("PHImageManager info: \(info)")
            }
            if let image = image {
                print("✅ Отримано повне зображення для \(self.id)")
            } else {
                print("❌ Не вдалося завантажити зображення для \(self.id)")
            }
            completion(image)
        }
    }
}
