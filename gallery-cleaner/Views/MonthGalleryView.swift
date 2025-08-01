import SwiftUI
import UIKit

struct MonthGalleryView: View {
    let month: String
    let photos: [PhotoItem]

    @Binding var selectedTab: Int
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var swipeDirection: Int = 0
    @State private var showHeart = false

    @EnvironmentObject var trashManager: TrashManager
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    @Environment(\.theme) private var theme
    @EnvironmentObject var storeKit: StoreKitManager
    @ObservedObject var localization = LocalizationManager.shared

    var filteredPhotos: [PhotoItem] {
        return photos
            .filter { !trashManager.trashedPhotos.contains($0) }
            .sorted { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
    }

    var body: some View {
        VStack {
            if filteredPhotos.isEmpty {
                Text("empty_month_list".localized(with: month))
                    .foregroundColor(.secondary)
            } else {
                ZStack {
                    theme.background.ignoresSafeArea()

                    ZStack {
                        ForEach([currentIndex - 1, currentIndex, currentIndex + 1], id: \.self) { index in
                            if let photo = filteredPhotos[safe: index] {
                                PhotoView(photoItem: photo)
                                    .id(photo.id)
                                    .opacity(index == currentIndex && isSwipingUp ? 0.4 : 1.0)
                                    .blur(radius: isSwipingUp && index == currentIndex ? 8 : 0)
                                    .rotationEffect(index == currentIndex ? .degrees((offset.width / CGFloat(10)).clamped(to: -10...10)) : .zero)
                                    .scaleEffect(index == currentIndex ? 1.0 : 0.9)
                                    .offset(
                                        x: offset.width + CGFloat(index - currentIndex) * UIScreen.main.bounds.width,
                                        y: index == currentIndex ? offset.height : 0
                                    )
                            }
                        }

                        if isSwipingUp {
                            Image(systemName: "trash.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(theme.trash)
                                .opacity(0.8)
                                .offset(x: offset.width, y: offset.height)
                                .zIndex(1)
                                .transition(.opacity)
                        }
                        if isSwipingDown {
                            Image(systemName: "heart.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.red)
                                .opacity(0.8)
                                .offset(x: offset.width, y: offset.height)
                                .zIndex(1)
                                .transition(.opacity)
                        }

                        

                        if showHeart {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.red)
                                .opacity(0.9)
                                .scaleEffect(1.2)
                                .transition(.scale)
                                .zIndex(2)
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                offset = gesture.translation
                                swipeDirection = gesture.translation.width > 0 ? -1 : 1
                            }
                            .onEnded { gesture in
                                handleSwipe(gesture: gesture)
                                offset = .zero
                            }
                    )

                    VStack {
                        Spacer()
                        if !trashManager.trashedPhotos.isEmpty {
                            Button(action: {
                                selectedTab = 3
                            }) {
                                Text("go_to_trash".localized(with: trashManager.trashedPhotos.count))
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(theme.card.opacity(0.9))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .navigationBarTitle(month, displayMode: .inline)
    }

    private func handleSwipe(gesture: DragGesture.Value) {
        let horizontal = gesture.translation.width
        let vertical = gesture.translation.height

        if abs(horizontal) > abs(vertical) {
            if horizontal < -50 && currentIndex < filteredPhotos.count - 1 {
                withAnimation {
                    currentIndex += 1
                }
            } else if horizontal > 50 && currentIndex > 0 {
                withAnimation {
                    currentIndex -= 1
                }
            }
        } else {
            let currentPhoto = filteredPhotos[currentIndex]

            if vertical < -80 {
                trashManager.addToTrash(currentPhoto)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                
            } else if vertical > 80 {
                viewModel.setFavorite(true, for: currentPhoto)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.easeOut) {
                    showHeart = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        showHeart = false
                    }
                }
            }
        }
    }

    private func moveToNext() {
        if currentIndex < filteredPhotos.count - 1 {
            withAnimation {
                currentIndex += 1
            }
        } else if currentIndex > 0 {
            withAnimation {
                currentIndex -= 1
            }
        }
    }
}

private extension MonthGalleryView {
    var isSwipingUp: Bool {
        offset.height < -30
    }
    var isSwipingDown: Bool {
        offset.height > 30
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
