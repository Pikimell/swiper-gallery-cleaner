import SwiftUI

struct PhotoThumbnailView: View {
    let photo: PhotoItem
    var width: CGFloat = 100
    var height: CGFloat = 100
    let holdDuration: Double = 1.0

    @State private var image: UIImage?
    @State private var fullImage: UIImage?
    @State private var showFullScreen = false
    @State private var isLoadingFullImage = false
    @Environment(\.theme) private var theme

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
                    .cornerRadius(8)
                    .drawingGroup()
            } else {
                Rectangle()
                    .fill(theme.border.opacity(0.3))
                    .frame(width: width, height: height)
                    .cornerRadius(8)
                    .overlay(ProgressView())
            }

            if photo.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                    .padding(6)
            }
        }
        .frame(width: width, height: height)
        .contentShape(Rectangle())
        .onAppear {
            loadThumbnail()
        }
        .onLongPressGesture(minimumDuration: holdDuration, maximumDistance: 10) {
            if fullImage != nil {
                showFullScreen = true
            } else if !isLoadingFullImage {
                isLoadingFullImage = true
                print("🔄 Завантаження повного зображення для \(photo.id)")
                photo.fullSizeImage { result in
                    DispatchQueue.main.async {
                        self.isLoadingFullImage = false
                        if let result = result {
                            print("✅ Отримано повне зображення для \(photo.id)")
                            self.fullImage = result
                            self.showFullScreen = true
                        } else {
                            print("❌ Не вдалося отримати повне зображення для \(photo.id)")
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { showFullScreen && fullImage != nil },
            set: { showFullScreen = $0 }
        )) {
            fullScreenImage
        }
    }

    // MARK: - Завантаження мініатюри
    private func loadThumbnail() {
        let cacheKey = photo.id
        if let cached = ImageCacheManager.shared.getImage(for: cacheKey) {
            self.image = cached
        } else {
            let scale = UIScreen.main.scale
            let targetSize = CGSize(width: width * scale, height: height * scale)
            photo.thumbnail(targetSize: targetSize) { result in
                DispatchQueue.main.async {
                    if let result = result {
                        print("✅ Завантажено мініатюру для \(photo.id)")
                        ImageCacheManager.shared.setImage(result, for: cacheKey)
                        self.image = result
                    } else {
                        print("❌ Не вдалося завантажити мініатюру для \(photo.id)")
                    }
                }
            }
        }
    }

    // MARK: - Показати повнорозмірне зображення
    private func showOriginalImage() {
        if let fullImage = fullImage {
            print("📸 Повне зображення вже завантажено — відкриваємо")
            showFullScreen = true
        } else if !isLoadingFullImage {
            print("🔄 Завантаження повного зображення для \(photo.id)")
            isLoadingFullImage = true
            photo.fullSizeImage { result in
                DispatchQueue.main.async {
                    self.isLoadingFullImage = false
                    if let result = result {
                        print("✅ Отримано повне зображення для \(photo.id)")
                        self.fullImage = result
                        self.showFullScreen = true
                    } else {
                        print("❌ Не вдалося отримати повне зображення для \(photo.id)")
                    }
                }
            }
        }
    }

    // MARK: - Повноекранне зображення
    @ViewBuilder
    private var fullScreenImage: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let img = fullImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        showFullScreen = false
                    }
                    .onAppear {
                        print("👀 Відображення повного зображення для \(photo.id)")
                    }
            } else {
                ProgressView()
                    .scaleEffect(1.5)
                    .foregroundColor(.white)
                    .onTapGesture {
                        showFullScreen = false
                    }
                    .onAppear {
                        print("⏳ Очікування зображення для \(photo.id)")
                    }
            }
        }
    }
}
