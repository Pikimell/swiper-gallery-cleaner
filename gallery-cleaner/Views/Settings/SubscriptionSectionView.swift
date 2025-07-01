import SwiftUI

enum SubscriptionStatus: String {
    case free, pro
}

struct SubscriptionSectionView: View {
    @AppStorage("subscriptionStatus") private var subscriptionStatusRaw: String = "free"
    @Environment(\.theme) private var theme

    private var subscriptionStatus: SubscriptionStatus {
        SubscriptionStatus(rawValue: subscriptionStatusRaw) ?? .free
    }

    var body: some View {
        Section(header: Text("settings_subscription_header".localized)) {
            HStack {
                Label("settings_current_plan".localized, systemImage: "person.crop.circle")
                Spacer()
                Text(subscriptionStatus == .pro ? "Pro" : "Free")
                    .foregroundColor(subscriptionStatus == .pro ? .green : .gray)
                    .fontWeight(.semibold)
            }

            if subscriptionStatus == .free {
                Button(action: {
                    // Запуск покупки Pro
                }) {
                    Label("settings_upgrade_pro".localized, systemImage: "star.fill")
                        .foregroundColor(theme.accent)
                }
            }

            Button(action: {
                // Відновлення покупок (Restore Purchases)
            }) {
                Label("settings_restore_purchases".localized, systemImage: "arrow.clockwise")
                    .foregroundColor(theme.textPrimary)
            }
        }
    }
}
