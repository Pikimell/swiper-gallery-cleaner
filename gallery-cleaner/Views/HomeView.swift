
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = PhotoLibraryViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.authorizationStatus == .denied || viewModel.authorizationStatus == .restricted {
                    Text("Доступ до фото заборонено. Надати дозвіл у налаштуваннях.")
                        .padding()
                } else if viewModel.isLoading {
                    ProgressView("Завантаження фото...")
                } else {
                    List {
                        ForEach(viewModel.groupedPhotos.keys.sorted(by: >), id: \.self) { month in
                            NavigationLink(destination: MonthGalleryView(month: month, photos: viewModel.groupedPhotos[month] ?? [])) {
                                HStack {
                                    Text(month)
                                    Spacer()
                                    Text("\(viewModel.groupedPhotos[month]?.count ?? 0) фото")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Місяці")
        }
    }
}
