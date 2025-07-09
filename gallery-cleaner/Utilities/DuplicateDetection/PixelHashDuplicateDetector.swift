//
//  PixelHashDuplicateDetector.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 10.07.2025.
//

import Foundation
import UIKit
import CoreImage

/// Відповідає за виявлення візуально схожих зображень через dHash (difference hash).
struct PixelHashDuplicateDetector {

    // MARK: - Конфігурація алгоритму

    struct Configuration {
        static let hashWidth: Int = 9     // ширина зображення для dHash
        static let hashHeight: Int = 8    // висота зображення для dHash
        static let targetSize = CGSize(width: 150, height: 150) // розмір для ресайзу
        static let threshold: Int = 7     // максимальна гамінгова відстань
    }

    /// Створює dHash для UIImage (розміром 9x8), повертає 64-бітовий хеш у вигляді рядка з 0 та 1
    static func generateDHash(for image: UIImage) -> String? {
        guard let resized = image.resizeMaintainingAspect(to: CGSize(width: Configuration.hashWidth, height: Configuration.hashHeight)),
              let grayscale = resized.grayscale(),
              let pixelData = grayscale.pixelIntensityArray() else {
            return nil
        }

        var hash = ""
        for row in 0..<Configuration.hashHeight {
            for col in 0..<(Configuration.hashWidth - 1) {
                let left = pixelData[row * Configuration.hashWidth + col]
                let right = pixelData[row * Configuration.hashWidth + col + 1]
                hash.append(left > right ? "1" : "0")
            }
        }

        return hash
    }

    /// Обчислює Hamming distance між двома хешами
    static func hammingDistance(_ a: String, _ b: String) -> Int {
        guard a.count == b.count else { return Int.max }
        return zip(a, b).filter { $0 != $1 }.count
    }

    /// Групує схожі фото з відстанню ≤ threshold, тільки в межах одного дня
    static func groupSimilarPhotos(from photos: [PhotoItem],
                                   targetSize: CGSize = Configuration.targetSize,
                                   threshold: Int = Configuration.threshold,
                                   progress: ((Int) -> Void)? = nil,
                                   completion: @escaping ([[PhotoItem]]) -> Void) {

        // 1. Групуємо фото за датою (рік, місяць, день)
        let calendar = Calendar.current

        let validPhotos = photos.compactMap { photo -> (Date, PhotoItem)? in
            guard let date = photo.creationDate else { return nil }
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            if let dayOnly = calendar.date(from: components) {
                return (dayOnly, photo)
            } else {
                return nil
            }
        }

        let groupedByDate = Dictionary(grouping: validPhotos, by: { $0.0 })
            .mapValues { $0.map { $0.1 } }

        var allGroups: [[PhotoItem]] = []
        let outerGroup = DispatchGroup()
        var processed = 0
        let total = photos.count
        let resultQueue = DispatchQueue(label: "result.merge.queue")

        for (_, sameDayPhotos) in groupedByDate {
            outerGroup.enter()

            // внутрішній хеш мап для конкретної дати
            var hashMap: [(hash: String, photo: PhotoItem)] = []
            let innerGroup = DispatchGroup()

            for photo in sameDayPhotos {
                innerGroup.enter()

                if let cachedHash = DuplicateScanCache.shared.getPixelHash(for: photo.id) {
                    hashMap.append((hash: cachedHash, photo: photo))
                    DispatchQueue.main.async {
                        processed += 1
                        progress?(processed)
                    }
                    innerGroup.leave()
                    continue
                }

                photo.thumbnail(targetSize: targetSize) { image in
                    defer {
                        DispatchQueue.main.async {
                            processed += 1
                            progress?(processed)
                        }
                        innerGroup.leave()
                    }

                    guard let image = image,
                          let hash = generateDHash(for: image) else { return }

                    DuplicateScanCache.shared.setPixelHash(hash, for: photo.id)
                    hashMap.append((hash: hash, photo: photo))
                }
            }

            innerGroup.notify(queue: .global(qos: .userInitiated)) {
                var used = Set<Int>()
                var dateGroups: [[PhotoItem]] = []

                for i in 0..<hashMap.count {
                    if used.contains(i) { continue }
                    var group = [hashMap[i].photo]
                    used.insert(i)

                    for j in (i + 1)..<hashMap.count {
                        if used.contains(j) { continue }

                        let distance = hammingDistance(hashMap[i].hash, hashMap[j].hash)
                        if distance <= threshold {
                            group.append(hashMap[j].photo)
                            used.insert(j)
                        }
                    }

                    if group.count > 1 {
                        dateGroups.append(group)
                    }
                }

                resultQueue.async(flags: .barrier) {
                    allGroups.append(contentsOf: dateGroups)
                    outerGroup.leave()
                }
            }
        }

        outerGroup.notify(queue: .main) {
            completion(allGroups)
        }
    }
}
