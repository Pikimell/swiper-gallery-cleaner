import SwiftUI

enum ThumbnailSize: String, CaseIterable, Identifiable {
    case small, medium, large

    var id: String { self.rawValue }

    var localizedTitle: String {
        switch self {
        case .small: return "thumb_size_small".localized
        case .medium: return "thumb_size_medium".localized
        case .large: return "thumb_size_large".localized
        }
    }
}

struct AnimationSectionView: View {
    @AppStorage("isSwipeAnimationEnabled") private var isSwipeAnimationEnabled: Bool = true
    @AppStorage("thumbnailSize") private var thumbnailSize: ThumbnailSize = .medium
    @Environment(\.theme) private var theme

    var body: some View {
        Section(header: Text("settings_interface_header".localized)) {
            Toggle(isOn: $isSwipeAnimationEnabled) {
                Label("settings_swipe_animation".localized, systemImage: "hand.draw")
            }
            .toggleStyle(SwitchToggleStyle(tint: theme.accent))

            Picker("settings_thumbnail_size".localized, selection: $thumbnailSize) {
                ForEach(ThumbnailSize.allCases) { size in
                    Text(size.localizedTitle).tag(size)
                }
            }
        }
    }
}
