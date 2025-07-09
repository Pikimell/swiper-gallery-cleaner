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
        loadFromDisk()
    }

    // MARK: - Папка кешу
    private let fileManager = FileManager.default
    private lazy var cacheDirectory: URL = {
        let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("ImageHashes")
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }()

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
        saveDictionary(sha256Hashes, to: "sha256.json")
    }

    // MARK: - PixelHash
    func getPixelHash(for photoID: String) -> String? {
        return pixelHashes[photoID]
    }

    func setPixelHash(_ hash: String, for photoID: String) {
        pixelHashes[photoID] = hash
        saveDictionary(pixelHashes, to: "pixel.json")
    }

    // MARK: - Vision FeaturePrint (RAM only)
    func getVisionPrint(for photoID: String) -> VNFeaturePrintObservation? {
        return visionPrints[photoID]
    }

    func setVisionPrint(_ observation: VNFeaturePrintObservation, for photoID: String) {
        visionPrints[photoID] = observation
    }

    // MARK: - Очищення
    func clearAll() {
        sha256Hashes.removeAll()
        pixelHashes.removeAll()
        visionPrints.removeAll()

        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Розмір кешу
    func totalCacheSizeInBytes() -> Int {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else { return 0 }
        return files.reduce(0) { total, fileURL in
            let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return total + size
        }
    }

    // MARK: - Приватні методи
    private func fileURL(for name: String) -> URL {
        return cacheDirectory.appendingPathComponent(name)
    }

    private func saveDictionary(_ dict: [String: String], to filename: String) {
        let url = fileURL(for: filename)
        if let data = try? JSONEncoder().encode(dict) {
            try? data.write(to: url)
        }
    }

    private func loadFromDisk() {
        if let data = try? Data(contentsOf: fileURL(for: "sha256.json")),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            sha256Hashes = decoded
        }

        if let data = try? Data(contentsOf: fileURL(for: "pixel.json")),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            pixelHashes = decoded
        }
    }
}
