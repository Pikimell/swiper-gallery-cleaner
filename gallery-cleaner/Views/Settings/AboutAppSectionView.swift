import SwiftUI

struct AboutAppSectionView: View {
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "v\(version) (\(build))"
    }

    @Environment(\.theme) private var theme

    var body: some View {
        Section {
            VStack(spacing: 8) {
                Text("Gallery Cleaner v\(appVersion)")
                    .font(.headline)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)

                Text("Pashchenko Volodymyr")
                    .font(.subheadline)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)

                Button {
                    if let url = URL(string: "https://yourwebsite.com") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("settings_app_website".localized)
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                        .underline()
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}
