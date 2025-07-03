
import Foundation
import Photos
import SwiftUI

class PhotoLibraryViewModel: ObservableObject {
    @Published var groupedPhotos: [String: [PhotoItem]] = [:]
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading = false

    init() {
        checkPhotoLibraryPermission()
    }

    // Перевірити та запитати дозвіл
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

    // Завантажити та згрупувати фото
    func fetchPhotos() {
        isLoading = true
        var grouped: [String: [PhotoItem]] = [:]

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        assets.enumerateObjects { asset, _, _ in
            let item = PhotoItem(asset: asset)
            guard let date = item.creationDate else { return }

            let monthYear = Self.monthYearString(from: date) // Наприклад "Січень 2025"
            let parts = monthYear.split(separator: " ")
            guard parts.count == 2 else { return }

            let monthName = String(parts[0])
            guard let monthNumber = Self.monthNumber(from: monthName) else { return }

            let displayKey = "\(monthNumber) \(monthYear)"  // "01 Січень 2025"
            grouped[displayKey, default: []].append(item)
        }

        DispatchQueue.main.async {
            let sortedGrouped = grouped.sorted { lhs, rhs in
                let lhsKey = lhs.key.prefix(2)  // перші 2 символи — номер місяця
                let rhsKey = rhs.key.prefix(2)
                return lhsKey < rhsKey
            }
            self.groupedPhotos = Dictionary(uniqueKeysWithValues: sortedGrouped)
            self.isLoading = false
        }
    }

    static func monthYearString(from date: Date) -> String {
    let formatter = DateFormatter()
    
    // Витягуємо вибрану мову з AppStorage
    let selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? Locale.current.language.languageCode?.identifier ?? "en"
    formatter.locale = Locale(identifier: selectedLanguage)

    formatter.dateFormat = "LLLL yyyy"
    return formatter.string(from: date).capitalized
    }
    
    static func monthNumber(from monthName: String) -> String? {
        let formatter = DateFormatter()
        let selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? Locale.current.language.languageCode?.identifier ?? "en"
        formatter.locale = Locale(identifier: selectedLanguage)
        formatter.dateFormat = "LLLL"

        for month in 1...12 {
            let dateComponents = DateComponents(calendar: Calendar.current, year: 2000, month: month)
            if let date = dateComponents.date {
                let name = formatter.string(from: date)
                if name.lowercased() == monthName.lowercased() {
                    return String(format: "%02d", month)
                }
            }
        }
        return nil
    }
    
    func refreshPhotos() {
        groupedPhotos = [:]
        fetchPhotos()
    }
}
