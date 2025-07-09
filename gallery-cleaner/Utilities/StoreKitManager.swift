import Foundation
import StoreKit

@MainActor
final class StoreKitManager: ObservableObject {
    @Published var isProUser: Bool = UserDefaults.standard.bool(forKey: "isProUser")
    @Published var product: Product?
    private let productID = "gallery_easy_cleaner_vip"

    init() {
        Task {
            await fetchProduct()
            await updatePurchasedStatus()
        }
    }

    /// Loads product metadata from the App Store.
    func fetchProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
        } catch {
            print("❌ Failed to fetch product: \(error)")
        }
    }

    /// Checks current entitlements to determine ownership of the premium upgrade.
    func updatePurchasedStatus() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == productID {
                isProUser = true
                UserDefaults.standard.set(true, forKey: "isProUser")
                return
            }
        }
        isProUser = false
        UserDefaults.standard.set(false, forKey: "isProUser")
    }

    /// Initiates the purchase flow for the premium upgrade.
    func purchase() async {
        guard let product else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    isProUser = true
                    UserDefaults.standard.set(true, forKey: "isProUser")
                    await transaction.finish()
                }
            default:
                break
            }
        } catch {
            print("❌ Purchase failed: \(error)")
        }
    }

    /// Restores previously completed purchases.
    func restore() async {
        do {
            try await AppStore.sync()
            await updatePurchasedStatus()
        } catch {
            print("❌ Error restoring purchases: \(error)")
        }
    }
}
