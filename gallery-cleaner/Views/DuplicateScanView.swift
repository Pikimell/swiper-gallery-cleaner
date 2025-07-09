import SwiftUI

enum DuplicateScanMode: String, CaseIterable, Identifiable {
    case pixel
    case exact
    

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .pixel: return "scan_mode_pixel".localized
        case .exact: return "scan_mode_exact".localized
        }
    }
}

struct DuplicateScanView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    @EnvironmentObject var trashManager: TrashManager
    @Environment(\.theme) private var theme

    @State private var selectedMode: DuplicateScanMode = .pixel
    @State private var isScanning = false
    @State private var resultGroups: [[PhotoItem]] = []

    @State private var scannedCount: Int = 0
    @State private var totalToScan: Int = 0

    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
    private var thumbSize: CGFloat {
        (UIScreen.main.bounds.width - 32) / 3
    }

    var body: some View {
        NavigationView {
            VStack {
                modeSelector

                if isScanning {
                    VStack(spacing: 10) {
                        Spacer().frame(height: 24)
                        ProgressView("scan_in_progress".localized)
                        Text("\(scannedCount)/\(totalToScan) photos scanned")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding()
                } else if !resultGroups.isEmpty {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(resultGroups.indices, id: \.self) { groupIndex in
                                VStack(alignment: .leading, spacing: 8) {
                                    LazyVGrid(columns: columns, spacing: 8) {
                                        ForEach(resultGroups[groupIndex], id: \.id) { photo in
                                            ZStack(alignment: .topTrailing) {
                                                PhotoThumbnailView(
                                                    photo: photo,
                                                    width: thumbSize,
                                                    height: thumbSize
                                                )
                                                .opacity(trashManager.trashedPhotos.contains(photo) ? 0.4 : 1.0)
                                                .onTapGesture {
                                                    toggleTrash(photo)
                                                }

                                                if trashManager.trashedPhotos.contains(photo) {
                                                    Image(systemName: "trash.circle.fill")
                                                        .foregroundColor(theme.trash)
                                                        .padding(4)
                                                }
                                            }
                                        }
                                    }

                                    Divider()
                                        .padding(.top, 4)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 80)
                    }
                } else {
                    Spacer()
                }

                if containsTrashedPhotos {
                    Button(action: {
                        selectedTab = 3 // перейти до TrashView
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
            .navigationTitle("scan_title".localized)
            .onAppear {
                clearScanResults()
            }
        }
    }
    
    private func clearScanResults() {
        resultGroups = []
        scannedCount = 0
        totalToScan = 0
        isScanning = false
    }

    private var modeSelector: some View {
        VStack {
            Picker("scan_picker_label".localized, selection: $selectedMode) {
                ForEach(DuplicateScanMode.allCases) { mode in
                    Text(mode.localizedTitle).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            if !isScanning {
                Button {
                    runScan()
                } label: {
                    Text("scan_start".localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
        }
    }

    private func toggleTrash(_ photo: PhotoItem) {
        if trashManager.trashedPhotos.contains(photo) {
            trashManager.restorePhoto(photo)
        } else {
            trashManager.addToTrash(photo)
        }
    }

    private var containsTrashedPhotos: Bool {
        resultGroups.flatMap { $0 }.contains(where: { trashManager.trashedPhotos.contains($0) })
    }

    private func runScan() {
        guard !isScanning else { return }

        isScanning = true
        resultGroups = []
        scannedCount = 0

        let photos = viewModel.groupedPhotos.values.flatMap { $0 }
        totalToScan = photos.count

        let updateProgress: (Int) -> Void = { current in
            DispatchQueue.main.async {
                scannedCount = current
            }
        }

        let complete: ([[PhotoItem]]) -> Void = { groups in
            let sortedGroups = groups
                .map { group in
                    group.sorted { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
                }
                .sorted { first, second in
                    let firstDate = first.first?.creationDate ?? .distantPast
                    let secondDate = second.first?.creationDate ?? .distantPast
                    return firstDate > secondDate
                }

            DispatchQueue.main.async {
                resultGroups = sortedGroups
                isScanning = false
            }
        }

        switch selectedMode {
        case .exact:
            SHA256DuplicateDetector.groupDuplicates(
                from: photos,
                targetSize: CGSize(width: 150, height: 150),
                progress: updateProgress,
                completion: complete
            )
        case .pixel:
            PixelHashDuplicateDetector.groupSimilarPhotos(
                from: photos,
                targetSize: CGSize(width: 100, height: 100),
                threshold: 6,
                progress: updateProgress,
                completion: complete
            )
//        case .vision:
//            VisionFeaturePrintDetector.groupSimilarPhotos(
//                from: photos,
//                targetSize: CGSize(width: 224, height: 224),
//                threshold: 0.05,
//                progress: updateProgress,
//                completion: complete
//            )
        }
    }
}
