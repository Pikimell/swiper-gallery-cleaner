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
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(groupPhotosByYear(), id: \.key) { year, months in
                                Text("\(year)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)

                                ForEach(months, id: \.self) { month in
                                    if let count = viewModel.groupedPhotos[month]?.count {
                                        NavigationLink(value: month) {
                                            HStack {
                                                Text(month)
                                                    .foregroundColor(.white)
                                                    .padding()
                                                Spacer()
                                                Text("\(count) фото")
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.orange.opacity(0.9), Color.orange.opacity(0.6)]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .cornerRadius(12)
                                            .padding(.horizontal)
                                        }
                                    }
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

    private func groupPhotosByYear() -> [(key: String, value: [String])] {
        let keys = viewModel.groupedPhotos.keys
        let monthYearPairs = keys.compactMap { key -> (String, String)? in
            let parts = key.split(separator: " ")
            guard parts.count == 2 else { return nil }
            return (key, String(parts[1]))
        }

        let grouped = Dictionary(grouping: monthYearPairs, by: { $0.1 })
        return grouped.mapValues { $0.map { $0.0 }.sorted(by: >) }.sorted { $0.key > $1.key }
    }
}