import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = PhotoLibraryViewModel()
    @State private var path: [String] = [] // шлях навігації

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if viewModel.authorizationStatus == .denied || viewModel.authorizationStatus == .restricted {
                    Text("Доступ до фото заборонено. Надати дозвіл у налаштуваннях.")
                        .padding()
                } else if viewModel.isLoading {
                    ProgressView("Завантаження фото...")
                } else {
                    List {
                        ForEach(viewModel.groupedPhotos.keys.sorted(by: >), id: \.self) { month in
                            NavigationLink(value: month) {
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
            .navigationDestination(for: String.self) { month in
                MonthGalleryView(month: month, photos: viewModel.groupedPhotos[month] ?? [])
            }
        }
        .onAppear {
            path = []
        }
    }
}