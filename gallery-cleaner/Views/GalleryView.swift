import SwiftUI


struct GalleryView: View {
    @StateObject private var viewModel = PhotoLibraryViewModel()
    @EnvironmentObject var trashManager: TrashManager
    @State private var showTrash = false
    @Environment(\.theme) private var theme

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
            VStack {
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
                trashButton
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 0) {
                        Text("Gallery")
                            .foregroundColor(theme.accent)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Cleaner")
                            .foregroundColor(theme.accent.opacity(0.6))
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .sheet(isPresented: $showTrash) {
            TrashView()
                .environmentObject(trashManager)
                .environmentObject(viewModel)
        }
    }

    @ViewBuilder
    private var trashButton: some View {
        if allPhotos.contains(where: { trashManager.trashedPhotos.contains($0) }) {
            Button(action: {
                showTrash = true
            }) {
                Text("Перейти до смітника (\(trashManager.trashedPhotos.count))")
                    .font(.headline)
                    .foregroundColor(theme.textPrimary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(theme.card.opacity(0.9))
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
                            .foregroundColor(theme.trash)
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
