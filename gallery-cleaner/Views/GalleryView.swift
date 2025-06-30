import SwiftUI

struct GalleryView: View {
    @StateObject private var viewModel = PhotoLibraryViewModel()
    @EnvironmentObject var trashManager: TrashManager
    @State private var showTrash = false

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
                        photoGrid
                    }
                }
            }
            .navigationTitle("Уся галерея")
            trashButton
        }
        .sheet(isPresented: $showTrash) {
            TrashView()
                .environmentObject(trashManager)
                .environmentObject(viewModel)
        }
    }

    @ViewBuilder
    private var trashButton: some View {
        if !trashManager.trashedPhotos.isEmpty {
            Button(action: {
                showTrash = true
            }) {
                Text("Перейти до смітника (\(trashManager.trashedPhotos.count))")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(12)
                    .padding()
            }
        }
    }

    @ViewBuilder
    private var photoGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(allPhotos, id: \.id) { photo in
                photoCell(for: photo)
            }
        }
        .padding()
    }

    private func photoCell(for photo: PhotoItem) -> some View {
        let isTrashed = trashManager.trashedPhotos.contains(photo)

        return ZStack {
            PhotoThumbnailView(photo: photo,
                               width: UIScreen.main.bounds.width / 3 - 16,
                               height: UIScreen.main.bounds.width / 3 - 16)
                .opacity(isTrashed ? 0.4 : 1.0)
                .contentShape(Rectangle())
                .onTapGesture {
                    if isTrashed {
                        trashManager.restorePhoto(photo)
                    } else {
                        trashManager.addToTrash(photo)
                    }
                }

            if isTrashed {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "trash.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width / 3 - 16,
               height: UIScreen.main.bounds.width / 3 - 16)
        .clipped()
    }
}
