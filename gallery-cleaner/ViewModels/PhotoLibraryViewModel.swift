import Foundation
import Photos
import SwiftUI

class PhotoLibraryViewModel: ObservableObject {
    @Published var groupedPhotos: [String: [PhotoItem]] = [:]
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading = false

    private let calendar = Calendar.current

    init() {
        checkPhotoLibraryPermission()
    }

    // Позначити/зняти позначку "Улюблене" в системній галереї
    func setFavorite(_ value: Bool, for photo: PhotoItem) {
        let asset = photo.asset

        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest(for: asset)
            request.isFavorite = value
        } completionHandler: { success, error in
            if let error = error {
                print("❌ Помилка при зміні обраного: \(error.localizedDescription)")
            } else {
                print("✅ Фото оновлено як улюблене: \(success)")
            }
        }
    }
    
    func toggleFavorite(for photo: PhotoItem) {
        let asset = photo.asset

        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest(for: asset)
            request.isFavorite = !photo.isFavorite
        } completionHandler: { success, error in
            if let error = error {
                print("❌ Помилка при зміні обраного: \(error.localizedDescription)")
            } else {
                print("✅ Фото оновлено як улюблене: \(success)")
            }
        }
    }

    // Перевірка дозволів
    func checkPhotoLibraryPermission() {
        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        authorizationStatus = currentStatus

        switch currentStatus {
        case .authorized, .limited:
            fetchPhotos()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                DispatchQueue.main.async {
                    self?.authorizationStatus = status
                    if status == .authorized || status == .limited {
                        self?.fetchPhotos()
                    }
                }
            }
        default:
            break
        }
    }

    // Завантаження фото з групуванням за місяцями
    func fetchPhotos() {
        isLoading = true
        var grouped: [String: [PhotoItem]] = [:]

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        assets.enumerateObjects { asset, _, _ in
            let item = PhotoItem(asset: asset)
            guard let date = item.creationDate else { return }

            let monthYear = Self.monthYearString(from: date)
            let parts = monthYear.split(separator: " ")
            guard parts.count == 2 else { return }

            let monthName = String(parts[0])
            guard let monthNumber = Self.monthNumber(from: monthName) else { return }

            let displayKey = "\(monthNumber) \(monthYear)"
            grouped[displayKey, default: []].append(item)
        }

        DispatchQueue.main.async {
            let sortedGrouped = grouped.sorted { lhs, rhs in
                lhs.key < rhs.key
            }
            self.groupedPhotos = Dictionary(uniqueKeysWithValues: sortedGrouped)
            self.isLoading = false
        }
    }

    func refreshPhotos() {
        groupedPhotos = [:]
        fetchPhotos()
    }

    // Перетворення дати у формат "Січень 2025"
    static func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        let selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
            ?? Locale.current.language.languageCode?.identifier
            ?? "en"
        formatter.locale = Locale(identifier: selectedLanguage)
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }

    // Отримання номера місяця за назвою
    static func monthNumber(from monthName: String) -> String? {
        let formatter = DateFormatter()
        let selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
            ?? Locale.current.language.languageCode?.identifier
            ?? "en"
        formatter.locale = Locale(identifier: selectedLanguage)
        formatter.dateFormat = "LLLL"

        for month in 1...12 {
            var components = DateComponents()
            components.year = 2000
            components.month = month
            components.day = 1
            if let date = Calendar.current.date(from: components) {
                let name = formatter.string(from: date)
                if name.lowercased() == monthName.lowercased() {
                    return String(format: "%02d", month)
                }
            }
        }
        return nil
    }
}
