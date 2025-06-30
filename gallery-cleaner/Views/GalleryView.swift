
import SwiftUI

struct GalleryView: View {
    @StateObject private var viewModel = PhotoLibraryViewModel()

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var allPhotos: [PhotoItem] {
        viewModel.groupedPhotos.values.flatMap { $0 }
            .sorted { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.authorizationStatus == .denied || viewModel.authorizationStatus == .restricted {
                    Text("Доступ до фото заборонено.\nНадайте дозвіл у налаштуваннях.")
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.isLoading {
                    ProgressView("Завантаження фото…")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(allPhotos, id: \.id) { photo in
                                PhotoThumbnailView(photo: photo)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Уся галерея")
        }
    }
}
