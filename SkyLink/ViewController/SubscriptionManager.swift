//
//  SubscriptionManager.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import Foundation
import StoreKit

final class SubscriptionManager
{
    static let shared = SubscriptionManager()
    private init() {}

    // MARK: - Properties
    @Published private(set) var isPremiumUser: Bool = false

   
    /// Placeholder product ID — update later App Store subscription is created.
    private let subscriptionProductID = "com.skylink.placeholder.subscription"

    private var products: [Product] = []

    // MARK: - Public API

    /// Loads  subscription product from the App Store.
    func fetchProducts() async
    {
        do {
            let storeProducts = try await Product.products(for: [subscriptionProductID])
            self.products = storeProducts
            print("Fetched products: \(storeProducts)")
        } catch {
            print("ERROR fetching products: \(error)")
        }
    }

    /// Attempts to purchase the active subscription.
    func purchase() async -> Bool
    {
        guard let product = products.first else {
            print("No products loaded. Did you call fetchProducts()?")
            return false
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try verification.payloadValue
                await transaction.finish()
                await updateSubscriptionStatus()
                return true

            case .userCancelled:
                print("Purchase cancelled by user.")
                return false

            default:
                print("Purchase returned unexpected result.")
                return false
            }

        } catch {
            print("Purchase failed: \(error)")
            return false
        }
    }

    /// Restores past purchases
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            print("Restore successful.")
        } catch {
            print("ERROR restoring purchases: \(error)")
        }
    }

    /// Checks whether the user currently has an active subscription.
    func isSubcribed() -> Bool {
        return isPremiumUser
    }

    // MARK: - Subscription Checking

    @MainActor
    func updateSubscriptionStatus() async {
        var premium = false

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? result.payloadValue else { continue }

            if transaction.productID == subscriptionProductID {
                premium = true
                break
            }
        }

        self.isPremiumUser = premium
        print("Subscription status updated: \(premium)")
    }

    // MARK: - Subscription Updates Listener

    /// Listens for subscription renewals, upgrades, cancellations, etc.
    func listenForSubscriptionUpdates() {
        Task.detached {
            for await result in Transaction.updates {
                guard let transaction = try? result.payloadValue else { continue }
                await transaction.finish()
                await self.updateSubscriptionStatus()
            }
        }
    }
}
