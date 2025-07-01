import SwiftUI

struct PhotoThumbnailView: View {
    let photo: PhotoItem
    var width: CGFloat = 100
    var height: CGFloat = 100

    @State private var image: UIImage?
    @Environment(\.theme) private var theme

    var body: some View {
        ZStack {
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
        }
        .onAppear {
            let cacheKey = photo.id
            if let cached = ImageCacheManager.shared.getImage(for: cacheKey) {
                self.image = cached
            } else {
                photo.thumbnail(targetSize: CGSize(width: 150, height: 150)) { result in
                    if let result = result {
                        ImageCacheManager.shared.setImage(result, for: cacheKey)
                        self.image = result
                    }
                }
            }
        }
    }
}
