import SwiftUI


struct HomeView: View {
    @StateObject private var viewModel = PhotoLibraryViewModel()
    @State private var path: [String] = [] // шлях навігації
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.theme) private var theme
    @ObservedObject var localization = LocalizationManager.shared

    var body: some View {
        VStack(spacing: 8) {
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
            .padding(.top, 8)

            NavigationStack(path: $path) {
                Group {
                    if viewModel.authorizationStatus == .denied || viewModel.authorizationStatus == .restricted {
                        Text("home_access_danied".localized)
                            .padding()
                    } else if viewModel.isLoading {
                        ProgressView("home_load_photos".localized)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                Text("all_photos".localized)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(theme.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                                Button(action: {
                                    path.append("All")
                                }) {
                                    HStack {
                                        Text("pick_all".localized)
                                            .foregroundColor(theme.textPrimary)
                                            .padding()
                                        Spacer()
                                    }
                                    .padding(.leading)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [theme.accent, theme.accent.opacity(0.6)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                }
                                ForEach(groupPhotosByYear(), id: \.key) { year, months in
                                    Text("\(year)")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(theme.textSecondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)

                                    ForEach(months, id: \.self) { month in
                                        if let count = viewModel.groupedPhotos[month]?.count {
                                            NavigationLink(value: month) {
                                                HStack {
                                                    HStack(spacing: 12) {
                                                    // Витягуємо номер місяця
                                                    let number = String(month.prefix(2)) // перші 2 символи — "01", "02", ...

                                                    // Витягуємо назву без номера
                                                    let nameStartIndex = month.index(month.startIndex, offsetBy: 3)
                                                    let name = String(month[nameStartIndex...]) // усе після номера

                                                    Text(number)
                                                        .font(.caption)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(theme.accent)
                                                        .frame(width: 28, height: 28)
                                                        .background(Circle().fill(.white))

                                                    Text(name)
                                                        .foregroundColor(theme.textPrimary)
                                                }
                                                .padding()
                                                    Spacer()
                                                    Text("photo_count".localized(with: count))
                                                        .foregroundColor(theme.textSecondary)
                                                        .padding(.trailing)
                                                }
                                                .padding(.leading)
                                                .frame(maxWidth: .infinity)
                                                .background(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [theme.accent, theme.accent.opacity(0.6)]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .cornerRadius(12)
                                                .padding(.horizontal)
                                                .padding(.vertical, 4)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationDestination(for: String.self) { month in
                    MonthGalleryView(
                        month: month,
                        photos: month == "All"
                            ? viewModel.groupedPhotos.values.flatMap { $0 }
                            : viewModel.groupedPhotos[month] ?? []
                    )
                }
            }
            BannerAdView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                .frame(height: 50)
        }
        .background(theme.background)
        .onAppear {
            path = []
            viewModel.fetchPhotos()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.fetchPhotos()
            }
        }
    }

    private func groupPhotosByYear() -> [(key: String, value: [String])] {
        let keys = viewModel.groupedPhotos.keys
        let monthYearPairs = keys.compactMap { key -> (String, String)? in
            let parts = key.split(separator: " ")
            guard parts.count >= 3 else { return nil }
            let year = String(parts[2])  // третя частина — рік
            return (key, year)
        }

        let grouped = Dictionary(grouping: monthYearPairs, by: { $0.1 })  // групуємо по року
        return grouped
            .mapValues { $0.map { $0.0 }.sorted(by: >) }  // сортуємо місяці в межах року
            .sorted { $0.key > $1.key }  // сортуємо роки
    }
}
