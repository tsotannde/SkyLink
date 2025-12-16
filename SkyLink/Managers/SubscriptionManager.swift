//  SubscriptionManager.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//

import Foundation
import StoreKit

enum SubscriptionProducts
{
    static let premuiumSubscriptionsProducts: [String] = ["com.skylink.weekly","com.skylink.monthly","com.skylink.yearly"]
    static var defaultPricing: SubscriptionPricing = SubscriptionPricing(weekly: 2.99, monthly: 8.99, yearly: 49.99)
}

final class SubscriptionManager
{
 
    static let shared = SubscriptionManager()
    private init() {}
    private var isPremiumUser: Bool = false
    private let productIDs = SubscriptionProducts.premuiumSubscriptionsProducts
   
    
    func isSubcribed() -> Bool
    {
        return isPremiumUser
    }
    
    
}

//MARK: - Purchase
extension SubscriptionManager {
    
    enum PurchaseResult
    {
        case success
        case cancelled
        case failed(Error)
        case pending
    }
    
    @MainActor
    func purchase(tier: SubscriptionTier) async -> PurchaseResult {
        do {
            let products = try await Product.products(for: [tier.productID])
            
            guard let product = products.first else {
                print("Product not found for ID:", tier.productID)
                return .failed(NSError(domain: "ProductNotFound", code: 0))
            }
            
            print("Purchasing:", product.id)
            
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try verification.payloadValue
                await transaction.finish()
                
                print("Purchase successful:", transaction.productID)
                isPremiumUser = true
                return .success
                
            case .userCancelled:
                print("User cancelled purchase")
                return .cancelled
                
            case .pending:
                print("Purchase pending (SCA / Ask to Buy)")
                return .pending
                
            @unknown default:
                return .failed(NSError(domain: "UnknownPurchaseState", code: 0))
            }
            
        } catch {
            print("Purchase failed:", error)
            return .failed(error)
        }
    }
    
   
}
//MARK: - Free Trail
extension SubscriptionManager
{
    func isEligibleForFreeTrial() async -> Bool
    {
      
        do {
            let products = try await Product.products(for: productIDs)
            
            print("🧾 Loaded products:", products.map { $0.id })
            
            for product in products {
                print("──────────────")
                print("📦 Product ID:", product.id)
                
                guard let subscription = product.subscription else {
                    print("Not a subscription")
                    continue
                }
                
                if subscription.introductoryOffer == nil {
                    print("No introductory offer configured")
                } else {
                    print("Introductory offer exists")
                }
                
                let eligible = await subscription.isEligibleForIntroOffer
                print("Eligible for intro offer:", eligible)
                
                if subscription.introductoryOffer != nil && eligible {
                    print("🎉 At least one product is eligible for free trial")
                    return true
                }
            }
            
            print("No eligible introductory offers found")
            return false
        } catch {
            print("❌ Failed to check free trial eligibility:", error)
            return false
        }
    }
    
    
   //Checks Product (passed as a string) Eleigibity for a free trail. Returns true or false
    func checkProductElegibilityForTrail(productID: String) async -> Bool
    {
  
        do {
            AppLoggerManager.shared.log("[SubscriptionManager]: " + "Checking product \(productID) eligibility for trial")
            let products = try await Product.products(for: [productID])
            
            //PRODUCT INVALID or NOT FOUND
            guard let product = products.first, let subscription = product.subscription
            else
            {
                AppLoggerManager.shared.log("[SubscriptionManager]: Product not found or not a subscription for ID: \(productID)")
                return false
            }
            
            if subscription.introductoryOffer == nil
            {
                AppLoggerManager.shared.log("[SubscriptionManager]: No introductory offer configured for product \(productID)")
                return false
            }
            
            let eligible = await subscription.isEligibleForIntroOffer
            AppLoggerManager.shared.log("[SubscriptionManager]: Eligible for intro offer \(eligible) for product \(productID)")
            return eligible
        }
        catch
        {
            AppLoggerManager.shared.log("[SubscriptionManager]: Failed to check free trial eligibility for product \(productID). Error: \(error)")
            return false
        }
    }
}

extension SubscriptionManager
{
    /// Temporary v1 stub – always returns true
    /// Used to unblock premium-gated flows before receipt validation is implemented
    func isSubscribed() -> Bool
    {
        return true
    }
}
//MARK: - Pricing
extension SubscriptionManager
{
    func price(for tier: SubscriptionTier) async throws -> Double
    {
        let products = try await Product.products(for: [tier.productID])

        guard let product = products.first else {
            throw NSError(
                domain: "SubscriptionPricingError",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Product not found for tier: \(tier)"
                ]
            )
        }

        return NSDecimalNumber(decimal: product.price).doubleValue
    }
}

//MARK: - Restore Purchases
extension SubscriptionManager
{
    func restorePurchases() async -> Bool
        {
            AppLoggerManager.shared.log("[SubscriptionManager]: restorePurchases called (stub)")
            return false // TODO: implement StoreKit restore
        }
}



enum SubscriptionTier
{
    case weekly
    case monthly
    case yearly

    var title: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }

    var productID: String
    {
        switch self
        {
        case .weekly: return "com.skylink.weekly"
        case .monthly: return "com.skylink.monthly"
        case .yearly: return "com.skylink.yearly"
        }
    }
}



struct SubscriptionPricing
{
    let weekly: Double
    let monthly: Double
    let yearly: Double
}

extension SubscriptionPricing
{
    func price(for tier: SubscriptionTier) -> Double
    {
        switch tier {
        case .weekly:
            return weekly
        case .monthly:
            return monthly
        case .yearly:
            return yearly
        }
    }
}
