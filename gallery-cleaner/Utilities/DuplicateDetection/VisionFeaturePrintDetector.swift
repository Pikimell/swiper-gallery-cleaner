//
//  VisionFeaturePrintDetector.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 10.07.2025.
//

import Foundation
import UIKit
import Vision

/// Виявляє візуально схожі зображення за допомогою ML FeaturePrint (Vision).
struct VisionFeaturePrintDetector {

    /// Створює об'єкт VNFeaturePrintObservation для порівняння
    static func generateFeaturePrint(for image: UIImage,
                                     completion: @escaping (VNFeaturePrintObservation?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let request = VNGenerateImageFeaturePrintRequest { request, error in
            if let result = request.results?.first as? VNFeaturePrintObservation {
                completion(result)
            } else {
                completion(nil)
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    /// Обчислює відстань (0 — ідентичні; чим ближче до 1 — тим менше схожість)
    static func computeDistance(a: VNFeaturePrintObservation,
                                b: VNFeaturePrintObservation) -> Float? {
        var distance: Float = 0
        try? a.computeDistance(&distance, to: b)
        return distance
    }

    /// Групує подібні зображення з відстанню меншою за threshold (наприклад, 0.05)
    static func groupSimilarPhotos(from photos: [PhotoItem],
                                   targetSize: CGSize,
                                   threshold: Float = 0.05,
                                   progress: ((Int) -> Void)? = nil,
                                   completion: @escaping ([[PhotoItem]]) -> Void) {

        // Групування по даті (тільки рік-місяць-день)
        let groupedByDate = Dictionary(grouping: photos) { photo in
            Calendar.current.startOfDay(for: photo.creationDate ?? .distantPast)
        }

        var allGroups: [[PhotoItem]] = []
        let dispatchGroup = DispatchGroup()
        let total = groupedByDate.values.reduce(0) { $0 + $1.count }
        var processed = 0
        let lock = NSLock()

        for (_, dailyPhotos) in groupedByDate {
            dispatchGroup.enter()

            processDailyPhotos(dailyPhotos,
                               targetSize: targetSize,
                               threshold: threshold,
                               progress: { step in
                                   DispatchQueue.main.async {
                                       processed += 1
                                       progress?(processed)
                                   }
                               }) { dayGroups in
                lock.lock()
                allGroups.append(contentsOf: dayGroups)
                lock.unlock()
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(allGroups)
        }
    }
    
    private static func processDailyPhotos(_ photos: [PhotoItem],
                                           targetSize: CGSize,
                                           threshold: Float,
                                           progress: ((Int) -> Void)? = nil,
                                           completion: @escaping ([[PhotoItem]]) -> Void) {

        var photoPrints: [(photo: PhotoItem, print: VNFeaturePrintObservation)] = []
        let dispatchGroup = DispatchGroup()
        let accessQueue = DispatchQueue(label: "vision.feature.queue.daily", attributes: .concurrent)

        for photo in photos {
            dispatchGroup.enter()

            if let cachedPrint = DuplicateScanCache.shared.getVisionPrint(for: photo.id) {
                accessQueue.async(flags: .barrier) {
                    photoPrints.append((photo, cachedPrint))
                }
                DispatchQueue.main.async {
                    progress?(1)
                }
                dispatchGroup.leave()
                continue
            }

            photo.thumbnail(targetSize: targetSize) { image in
                guard let image = image else {
                    DispatchQueue.main.async {
                        progress?(1)
                    }
                    dispatchGroup.leave()
                    return
                }

                generateFeaturePrint(for: image) { featurePrint in
                    if let featurePrint = featurePrint {
                        DuplicateScanCache.shared.setVisionPrint(featurePrint, for: photo.id)
                        accessQueue.async(flags: .barrier) {
                            photoPrints.append((photo, featurePrint))
                        }
                    }

                    DispatchQueue.main.async {
                        progress?(1)
                    }

                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
            var used = Set<Int>()
            var groups: [[PhotoItem]] = []

            for i in 0..<photoPrints.count {
                if used.contains(i) { continue }
                var group = [photoPrints[i].photo]
                used.insert(i)

                for j in (i + 1)..<photoPrints.count {
                    if used.contains(j) { continue }

                    if let distance = computeDistance(a: photoPrints[i].print,
                                                      b: photoPrints[j].print),
                       distance < threshold {
                        group.append(photoPrints[j].photo)
                        used.insert(j)
                    }
                }

                if group.count > 1 {
                    groups.append(group)
                }
            }

            completion(groups)
        }
    }
}
