import UIKit
import SwiftUI

struct MonthGalleryView: View {
    let month: String
    let photos: [PhotoItem]

    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var swipeDirection: Int = 0
    @EnvironmentObject var trashManager: TrashManager
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    @State private var showTrash = false

    var filteredPhotos: [PhotoItem] {
        if month == "All" {
            return photos.sorted { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
        }
        return photos
            .filter { !trashManager.trashedPhotos.contains($0) }
            .sorted { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
    }

    var body: some View {
        VStack {
            if filteredPhotos.isEmpty {
                Text("Немає фото за \(month)")
                    .foregroundColor(.secondary)
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()

                    ZStack {
                        ZStack {
                            ForEach([currentIndex - 1, currentIndex, currentIndex + 1], id: \.self) { index in
                                if let photo = filteredPhotos[safe: index] {
                                    PhotoView(photoItem: photo)
                                        .id(photo.id)
                                        .opacity(index == currentIndex ? (isSwipingUp ? 0.4 : 1.0) : 0)
                                        .blur(radius: isSwipingUp && index == currentIndex ? 8 : 0)
                                        .rotationEffect(index == currentIndex + swipeDirection ? .degrees((offset.width / CGFloat(10)).clamped(to: -10...10)) : .zero)
                                        .scaleEffect(index == currentIndex ? 1.0 : 0.9)
                                        .offset(x: offset.width + CGFloat(index - currentIndex) * UIScreen.main.bounds.width,
                                                y: index == currentIndex ? offset.height : 0)
                                }
                            }

                            if isSwipingUp, let current = filteredPhotos[safe: currentIndex] {
                                ZStack {
                                    Image(systemName: "trash.circle.fill")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.red)
                                        .opacity(0.8)
                                }
                                .transition(.opacity)
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {
                        HStack {
                            Spacer()
                            VStack(alignment: .center) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("Свайп вгору — видалити")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.top, 20)
                            .padding(.trailing, 16)
                        }
                        Spacer()
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
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .navigationBarTitle(month, displayMode: .inline)
        .sheet(isPresented: $showTrash) {
            TrashView()
                .environmentObject(trashManager)
                .environmentObject(viewModel) 
        }
    }

    private func handleSwipe(gesture: DragGesture.Value) {
        let horizontal = gesture.translation.width
        let vertical = gesture.translation.height

        if abs(horizontal) > abs(vertical) {
            // Горизонтальні свайпи
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
            // Вертикальний свайп вгору
            if vertical < -80 {
                let removedPhoto = filteredPhotos[currentIndex]
                trashManager.addToTrash(removedPhoto)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                moveToNext()
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

    func xOffset(for index: Int) -> CGFloat {
        return 0
    }

    func yOffset(for index: Int) -> CGFloat {
        return 0
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
