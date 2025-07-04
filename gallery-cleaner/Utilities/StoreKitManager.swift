import Foundation
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    @Published var isPremiumUser = false
    private let productID = "your_product_id" // заміни на справжній ID підписки

    init() {
        Task {
            await updateSubscriptionStatus()
        }
    }

    func updateSubscriptionStatus() async {
        do {
            let products = try await Product.products(for: [productID])
            guard let product = products.first else { return }

            guard let subscription = product.subscription else { return }

            let statuses = try await subscription.status

            for status in statuses {
                switch status.state {
                case .subscribed:
                    isPremiumUser = true
                    UserDefaults.standard.set(true, forKey: "isPremium")
                    return
                default:
                    break
                }
            }

            isPremiumUser = false
            UserDefaults.standard.set(false, forKey: "isPremium")

        } catch {
            print("❌ Error checking subscription status: \(error)")
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            print("❌ Error restoring purchases: \(error)")
        }
    }
}
