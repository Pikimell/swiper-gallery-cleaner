import UIKit
import SwiftUI

struct MonthGalleryView: View {
    let month: String
    let photos: [PhotoItem]

    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @EnvironmentObject var trashManager: TrashManager

    var body: some View {
        VStack {
            if photos.isEmpty {
                Text("Немає фото за \(month)")
                    .foregroundColor(.secondary)
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()

                    if let current = photos[safe: currentIndex] {
                        PhotoView(photoItem: current)
                            .offset(offset)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        offset = gesture.translation
                                    }
                                    .onEnded { gesture in
                                        handleSwipe(gesture: gesture)
                                        offset = .zero
                                    }
                            )
                            .transition(.slide)
                            .animation(.easeInOut, value: offset)
                    }

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
                        Button(action: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Text("Перейти до смітника")
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
        .navigationBarTitle(month, displayMode: .inline)
    }

    private func handleSwipe(gesture: DragGesture.Value) {
        let horizontal = gesture.translation.width
        let vertical = gesture.translation.height

        if abs(horizontal) > abs(vertical) {
            // Горизонтальні свайпи
            if horizontal < -50 && currentIndex < photos.count - 1 {
                currentIndex += 1
            } else if horizontal > 50 && currentIndex > 0 {
                currentIndex -= 1
            }
        } else {
            // Вертикальний свайп вгору
            if vertical < -80 {
                let removedPhoto = photos[currentIndex]
                trashManager.addToTrash(removedPhoto)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                moveToNext()
            }
        }
    }

    private func moveToNext() {
        if currentIndex < photos.count - 1 {
            currentIndex += 1
        } else if currentIndex > 0 {
            currentIndex -= 1
        }
    }
}
