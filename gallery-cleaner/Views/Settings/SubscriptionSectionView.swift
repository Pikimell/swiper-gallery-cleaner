import SwiftUI

enum SubscriptionStatus: String {
    case free, pro
}

struct SubscriptionSectionView: View {
    @AppStorage("subscriptionStatus") private var subscriptionStatusRaw: String = "free"
    @Environment(\.theme) private var theme
    @EnvironmentObject var storeKit: StoreKitManager
    @State private var showSuccess = false

    private var subscriptionStatus: SubscriptionStatus {
        storeKit.isProUser ? .pro : .free
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
                    Task {
                        await storeKit.purchase()
                        if storeKit.isProUser { showSuccess = true }
                    }
                }) {
                    Label("settings_upgrade_pro".localized, systemImage: "star.fill")
                        .foregroundColor(theme.accent)
                }
            }

            Button(action: {
                Task { await storeKit.restore() }
            }) {
                Label("settings_restore_purchases".localized, systemImage: "arrow.clockwise")
                    .foregroundColor(theme.textPrimary)
            }
        }
        .alert("Purchase successful", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {}
        }
        .onChange(of: storeKit.isProUser) { newValue in
            subscriptionStatusRaw = newValue ? "pro" : "free"
        }
    }
}
