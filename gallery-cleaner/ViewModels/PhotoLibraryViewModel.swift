
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

            let monthYear = Self.monthYearString(from: date)
            grouped[monthYear, default: []].append(item)
        }

        DispatchQueue.main.async {
            // Очищення перед оновленням
            self.groupedPhotos.removeAll()
            // Сортування груп за ключем (місяць-рік)
            let sortedGrouped = grouped.sorted { 
                guard let date1 = $0.value.first?.creationDate,
                let date2 = $1.value.first?.creationDate else { return false }
                return date1 > date2 
            }
            self.groupedPhotos = Dictionary(uniqueKeysWithValues: sortedGrouped)
            self.isLoading = false
        }
    }

    static func monthYearString(from date: Date) -> String {
    let formatter = DateFormatter()
    
    // Витягуємо вибрану мову з AppStorage
    let selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? Locale.current.languageCode ?? "en"
    formatter.locale = Locale(identifier: selectedLanguage)

    formatter.dateFormat = "LLLL yyyy"
    return formatter.string(from: date).capitalized
}
}
