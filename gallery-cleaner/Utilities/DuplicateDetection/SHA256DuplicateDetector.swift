//
//  SHA256DuplicateDetector.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 09.07.2025.
//

import Foundation
import UIKit
import CryptoKit

/// Відповідає за виявлення точних дублікатів фото через SHA256 хешування.
struct SHA256DuplicateDetector {
    
    /// Генерує SHA256-хеш для переданого UIImage
    static func generateHash(for image: UIImage) -> String? {
        guard let data = image.pngData() else { return nil }
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Групує дублікати серед колекції PhotoItem на основі зображень з однаковим SHA256
    static func groupDuplicates(from photos: [PhotoItem],
                                targetSize: CGSize,
                                progress: ((Int) -> Void)? = nil,
                                completion: @escaping ([[PhotoItem]]) -> Void) {
        
        var hashMap: [String: [PhotoItem]] = [:]
        let accessQueue = DispatchQueue(label: "sha256.hashmap.queue", attributes: .concurrent)
        let dispatchGroup = DispatchGroup()
        let total = photos.count
        var processed = 0

        for photo in photos {
            dispatchGroup.enter()

            // Перевірка кешу
            if let cachedHash = DuplicateScanCache.shared.getSHA256(for: photo.id) {
                accessQueue.async(flags: .barrier) {
                    hashMap[cachedHash, default: []].append(photo)
                }
                DispatchQueue.main.async {
                    processed += 1
                    progress?(processed)
                }
                dispatchGroup.leave()
                continue
            }

            photo.thumbnail(targetSize: targetSize) { image in
                defer {
                    DispatchQueue.main.async {
                        processed += 1
                        progress?(processed)
                    }
                    dispatchGroup.leave()
                }

                guard let image = image,
                      let hash = generateHash(for: image) else { return }

                // Збереження в кеш
                DuplicateScanCache.shared.setSHA256(hash, for: photo.id)

                accessQueue.async(flags: .barrier) {
                    hashMap[hash, default: []].append(photo)
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            let duplicates = hashMap.values.filter { $0.count > 1 }
            completion(duplicates)
        }
    }
}
