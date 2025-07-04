import Foundation
import StoreKit

@MainActor
final class StoreKitManager: ObservableObject {
    @Published var isPremiumUser: Bool = false
    @Published var products: [Product] = []

    private let productID = "com.example.subscription" // Replace with your real product id
    private var updateListenerTask: Task<Void, Never>?

    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await requestProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Product Loading
    func requestProducts() async {
        do {
            products = try await Product.products(for: [productID])
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }

    // MARK: - Purchasing
    func purchaseSubscription() async {
        guard let product = products.first else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updateSubscriptionStatus()
            case .pending, .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            print("❌ Purchase error: \(error)")
        }
    }

    // MARK: - Status
    func updateSubscriptionStatus() async {
        var premium = false
        for await result in Transaction.currentEntitlements {
            if result.productID == productID && result.revocationDate == nil {
                premium = true
                break
            }
        }
        isPremiumUser = premium
        UserDefaults.standard.set(premium, forKey: "isPremium")
    }

    // MARK: - Restore
    func restore() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            print("❌ Error restoring purchases: \(error)")
        }
    }

    // MARK: - Transaction updates
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await verification in Transaction.updates {
                guard let self, let transaction = try? self.checkVerified(verification) else { continue }
                await self.updateSubscriptionStatus()
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let signed):
            return signed
        }
    }
}
