import SwiftUI

struct FeedbackSectionView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.theme) private var theme

    var body: some View {
        Section(header: Text("settings_feedback_header".localized)) {
            Button(action: {
                if let url = URL(string: "mailto:support@example.com?subject=GalleryCleaner Feedback") {
                    openURL(url)
                }
            }) {
                Label("settings_send_feedback".localized, systemImage: "envelope")
                    .foregroundColor(theme.textPrimary)
            }

            Button(action: {
                if let url = URL(string: "https://example.com/report-issue") {
                    openURL(url)
                }
            }) {
                Label("settings_report_problem".localized, systemImage: "exclamationmark.bubble")
                    .foregroundColor(theme.textPrimary)
            }

            Button(action: {
                if let url = URL(string: "https://example.com/help") {
                    openURL(url)
                }
            }) {
                Label("settings_help_faq".localized, systemImage: "questionmark.circle")
                    .foregroundColor(theme.textPrimary)
            }
        }
    }
}
