
import SwiftUI

struct PhotoView: View {
    let photoItem: PhotoItem

    @State private var image: UIImage?
    @Environment(\.theme) private var theme

    var body: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(theme.background)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(theme.background)
            }
        }
        .onAppear {
            photoItem.fullSizeImage { result in
                self.image = result
            }
        }
    }
}
