import SwiftUI
import GoogleMobileAds

struct GalleryView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    @EnvironmentObject var trashManager: TrashManager
    @EnvironmentObject var storeKit: StoreKitManager
    @State private var showTrash = false
    @State private var navigateToTrash = false
    @Environment(\.theme) private var theme
    @ObservedObject var localization = LocalizationManager.shared

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
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Group {
                        if viewModel.authorizationStatus == .denied || viewModel.authorizationStatus == .restricted {
                            Text("gallery_access_danied".localized)
                                .multilineTextAlignment(.center)
                                .padding()
                        } else if viewModel.isLoading {
                            ProgressView("home_load_photos".localized)
                        } else {
                            ScrollView {
                                photoGrid
                                    .padding(.bottom, 70) // Щоб банер не перекривав фото
                            }
                        }
                    }
                    trashButton
                }

                // Банер поверх усього
                if trashManager.trashedPhotos.isEmpty {
                    BannerAdView(adUnitID: "ca-app-pub-3940256099942544/2934735716") // Тестовий ID
                        .frame(width: 320, height: 50)
                        .background(Color.clear)
                        .padding(.bottom, 4)
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 0) {
                        Text("app_title_first".localized)
                            .foregroundColor(theme.accent)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("app_title_second".localized)
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
                selectedTab = 3 // індекс вкладки TrashView
            }) {
                Text("go_to_trash".localized(with: trashManager.trashedPhotos.count))
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
        .padding(.horizontal)
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
