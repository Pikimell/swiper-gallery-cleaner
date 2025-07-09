//
//  DuplicateScanCache.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 10.07.2025.
//

import Foundation
import Vision

final class DuplicateScanCache {
    static let shared = DuplicateScanCache()

    private init() {
        loadSHA256Cache()
        loadPixelHashCache()
    }

    // MARK: - Ключі для збереження
    private let sha256Key = "cache_sha256"
    private let pixelKey = "cache_pixel"

    // MARK: - Кеш у памʼяті
    private var sha256Hashes: [String: String] = [:]
    private var pixelHashes: [String: String] = [:]
    private var visionPrints: [String: VNFeaturePrintObservation] = [:]

    // MARK: - SHA256
    func getSHA256(for photoID: String) -> String? {
        return sha256Hashes[photoID]
    }

    func setSHA256(_ hash: String, for photoID: String) {
        sha256Hashes[photoID] = hash
        saveSHA256Cache()
    }

    // MARK: - PixelHash
    func getPixelHash(for photoID: String) -> String? {
        return pixelHashes[photoID]
    }

    func setPixelHash(_ hash: String, for photoID: String) {
        pixelHashes[photoID] = hash
        savePixelHashCache()
    }

    // MARK: - Vision FeaturePrint
    func getVisionPrint(for photoID: String) -> VNFeaturePrintObservation? {
        return visionPrints[photoID]
    }

    func setVisionPrint(_ observation: VNFeaturePrintObservation, for photoID: String) {
        visionPrints[photoID] = observation
    }

    // MARK: - Очищення
    func clearAll() {
        clearSHA()
        clearPixel()
        clearVision()
    }

    func clearSHA() {
        sha256Hashes.removeAll()
        UserDefaults.standard.removeObject(forKey: sha256Key)
    }

    func clearPixel() {
        pixelHashes.removeAll()
        UserDefaults.standard.removeObject(forKey: pixelKey)
    }

    func clearVision() {
        visionPrints.removeAll()
    }

    // MARK: - Збереження на диск
    private func saveSHA256Cache() {
        UserDefaults.standard.set(sha256Hashes, forKey: sha256Key)
    }

    private func savePixelHashCache() {
        UserDefaults.standard.set(pixelHashes, forKey: pixelKey)
    }

    // MARK: - Завантаження з диску
    private func loadSHA256Cache() {
        if let saved = UserDefaults.standard.dictionary(forKey: sha256Key) as? [String: String] {
            sha256Hashes = saved
        }
    }

    private func loadPixelHashCache() {
        if let saved = UserDefaults.standard.dictionary(forKey: pixelKey) as? [String: String] {
            pixelHashes = saved
        }
    }
}
