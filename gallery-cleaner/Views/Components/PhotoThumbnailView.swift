
import SwiftUI

struct PhotoThumbnailView: View {
    let photo: PhotoItem

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
                    .overlay(
                        ProgressView()
                    )
            }
        }
        .onAppear {
            photo.thumbnail(targetSize: CGSize(width: 150, height: 150)) { result in
                self.image = result
            }
        }
    }
}
