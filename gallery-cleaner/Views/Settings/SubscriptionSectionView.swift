import SwiftUI

struct SubscriptionSectionView: View {
    @EnvironmentObject private var storeKit: StoreKitManager
    @Environment(\.theme) private var theme

    var body: some View {
        Section(header: Text("settings_subscription_header".localized)) {
            HStack {
                Label("settings_current_plan".localized, systemImage: "person.crop.circle")
                Spacer()
                Text(storeKit.isSubscribed ? "Pro" : "Free")
                    .foregroundColor(storeKit.isSubscribed ? .green : .gray)
                    .fontWeight(.semibold)
            }

            if let product = storeKit.products.first, !storeKit.isSubscribed {
                HStack {
                    Text(product.displayName)
                    Spacer()
                    Text(product.displayPrice)
                }

                Button(action: {
                    Task { await storeKit.purchase(product) }
                }) {
                    Label("settings_upgrade_pro".localized, systemImage: "star.fill")
                        .foregroundColor(theme.accent)
                }
            }

            Button(action: {
                Task { await storeKit.updateSubscriptionStatus() }
            }) {
                Label("settings_restore_purchases".localized, systemImage: "arrow.clockwise")
                    .foregroundColor(theme.textPrimary)
            }
        }
    }
}
