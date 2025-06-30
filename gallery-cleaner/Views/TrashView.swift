
import SwiftUI

struct TrashView: View {
    @EnvironmentObject var trashManager: TrashManager

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            VStack {
                if trashManager.trashedPhotos.isEmpty {
                    Text("Кошик порожній")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(trashManager.trashedPhotos, id: \.id) { photo in
                                PhotoThumbnailView(photo: photo)
                                    .onTapGesture {
                                        trashManager.restorePhoto(photo)
                                    }
                            }
                        }
                        .padding()
                    }

                    Button(role: .destructive) {
                        trashManager.deleteAllFromLibrary()
                    } label: {
                        Text("Видалити все")
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
            .navigationTitle("Кошик")
        }
    }
}
