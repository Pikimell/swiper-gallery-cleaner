
import SwiftUI

struct PhotoThumbnailView: View {
    let photo: PhotoItem
    var width: CGFloat = 100
    var height: CGFloat = 100

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: width, height: height)
                    .cornerRadius(8)
                    .overlay(ProgressView())
            }
        }
        .onAppear {
            photo.thumbnail(targetSize: CGSize(width: 150, height: 150)) { result in
                self.image = result
            }
        }
    }
}