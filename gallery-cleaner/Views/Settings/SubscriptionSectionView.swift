import SwiftUI

struct SubscriptionSectionView: View {
    @EnvironmentObject var storeKit: StoreKitManager
    @Environment(\.theme) private var theme

    var body: some View {
        Section(header: Text("settings_subscription_header".localized)) {
            HStack {
                Label("settings_current_plan".localized, systemImage: "person.crop.circle")
                Spacer()
                Text(storeKit.isPremiumUser ? "Pro" : "Free")
                    .foregroundColor(storeKit.isPremiumUser ? .green : .gray)
                    .fontWeight(.semibold)
            }

            if storeKit.isPremiumUser {
                Text("settings_subscription_active".localized)
                    .foregroundColor(.green)
            } else {
                if let product = storeKit.products.first {
                    Button(action: {
                        Task { await storeKit.purchaseSubscription() }
                    }) {
                        Label("\("settings_upgrade_pro".localized) \(product.displayPrice)", systemImage: "star.fill")
                            .foregroundColor(theme.accent)
                    }
                } else {
                    ProgressView()
                }
            }

            Button(action: {
                Task { await storeKit.restore() }
            }) {
                Label("settings_restore_purchases".localized, systemImage: "arrow.clockwise")
                    .foregroundColor(theme.textPrimary)
            }
        }
    }
}

#Preview {
    SubscriptionSectionView()
        .environmentObject(StoreKitManager())
        .environment(\.theme, Theme.default)
}
