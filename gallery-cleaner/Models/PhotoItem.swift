
import Foundation
import Photos
import SwiftUI

struct PhotoItem: Identifiable, Hashable {
    let id: String            // Унікальний ідентифікатор (PHAsset.localIdentifier)
    let asset: PHAsset        // Системний об'єкт, що представляє фото
    let creationDate: Date?   // Дата створення фото

    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.creationDate = asset.creationDate
    }

    func thumbnail(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast

        imageManager.requestImage(for: asset,
                                   targetSize: targetSize,
                                   contentMode: .aspectFill,
                                   options: options) { image, _ in
            completion(image)
        }
    }

    func fullSizeImage(completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none

        imageManager.requestImage(for: asset,
                                   targetSize: PHImageManagerMaximumSize,
                                   contentMode: .aspectFit,
                                   options: options) { image, _ in
            completion(image)
        }
    }
}
