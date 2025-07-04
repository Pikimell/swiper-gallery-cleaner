import Foundation
import StoreKit
import SwiftUI

@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    private let subscriptionID = "com.pikimell.gallerycleaner.subscription"

    @Published var products: [Product] = []
    @Published var isSubscribed: Bool = false
    @AppStorage("isSubscribed") private var storedSubscription: Bool = false

    private init() {
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [subscriptionID])
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updateSubscriptionStatus()
            case .userCancelled, .pending:
                break
            default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    func updateSubscriptionStatus() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == subscriptionID,
               transaction.revocationDate == nil,
               (transaction.expirationDate ?? .distantFuture) > Date() {
                active = true
                break
            }
        }
        storedSubscription = active
        isSubscribed = active
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let signed):
            return signed
        case .unverified(_, let error):
            throw error
        }
    }
}
