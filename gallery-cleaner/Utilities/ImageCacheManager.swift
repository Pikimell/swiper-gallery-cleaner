//
//  ImageCacheManager.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 01.07.2025.
//

import Foundation
import UIKit
class ImageCacheManager {
    static let shared = ImageCacheManager()

    private let cache = NSCache<NSString, UIImage>()
    private var keys: Set<String> = []

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }

    func getImage(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
        keys.insert(key)
    }

    func totalCacheSizeInBytes() -> Int {
        var total = 0
        for key in keys {
            if let image = cache.object(forKey: key as NSString),
               let data = image.pngData() {
                total += data.count
            }
        }
        return total
    }

    func clearCache() {
        cache.removeAllObjects()
        keys.removeAll()
    }
}
