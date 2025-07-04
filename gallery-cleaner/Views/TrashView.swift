import SwiftUI

struct TrashView: View {
    @EnvironmentObject var trashManager: TrashManager
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    @ObservedObject var localization = LocalizationManager.shared
    @EnvironmentObject var storeKit: StoreKitManager

    @StateObject private var adManager = InterstitialAdManager(adUnitID: "ca-app-pub-3940256099942544/4411468910")
    @State private var showAd = false
    @State private var shouldDelete = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            VStack {
                if trashManager.trashedPhotos.isEmpty {
                    Text("trash_is_empty".localized)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(trashManager.trashedPhotos, id: \.id) { photo in
                                PhotoThumbnailView(photo: photo,
                                                   width: UIScreen.main.bounds.width / 3 - 16,
                                                   height: UIScreen.main.bounds.width / 3 - 16)
                                    .onTapGesture {
                                        trashManager.restorePhoto(photo)
                                    }
                            }
                        }
                        .padding()
                    }

                    Button(role: .destructive) {
                        if storeKit.isPremiumUser {
                            trashManager.deleteAllFromLibrary(viewModel: viewModel)
                        } else if let rootVC = UIApplication.shared.connectedScenes
                            .compactMap({ ($0 as? UIWindowScene)?.windows.first?.rootViewController })
                            .first {
                            adManager.showAd(from: rootVC)
                            shouldDelete = true
                        }
                    } label: {
                        Text("trash_delete_all".localized)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }
                }
            }
            .navigationTitle("trash_title".localized)
            .onAppear {
                if !storeKit.isPremiumUser {
                    adManager.loadAd()
                }
            }
            .onReceive(adManager.$didDismissAd) { dismissed in
                if dismissed && shouldDelete {
                    trashManager.deleteAllFromLibrary(viewModel: viewModel)
                    shouldDelete = false
                }
                if !storeKit.isPremiumUser {
                    adManager.loadAd()
                }
            }
        }
    }
}
