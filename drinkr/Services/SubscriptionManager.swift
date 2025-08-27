//
//  SubscriptionManager.swift
//  Sobbr
//
//  Created by Assistant on 8/26/25.
//

import Foundation
import StoreKit
import SwiftUI

enum SubscriptionTier: String, CaseIterable {
    case monthly = "sobbrmonthly"
    case yearly = "sobbryearly"
    
    var displayName: String {
        switch self {
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Annual"
        }
    }
    
    var price: String {
        switch self {
        case .monthly:
            return "$9.99/month"
        case .yearly:
            return "$29.99/year"
        }
    }
    
    var savings: String? {
        switch self {
        case .monthly:
            return nil
        case .yearly:
            return "Save 75%"
        }
    }
}

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var hasActiveSubscription = false
    @Published var isCheckingSubscription = false
    @Published var subscriptionExpiryDate: Date?
    @Published var currentSubscriptionTier: SubscriptionTier?
    @Published var showingPaywall = false
    @Published var paywallDismissedWithoutPurchase = false
    
    private var purchaseCompletionHandler: ((Bool) -> Void)?
    
    private init() {
        loadCachedSubscriptionStatus()
        Task {
            await updateSubscriptionStatus()
        }
    }
    
    func loadCachedSubscriptionStatus() {
        hasActiveSubscription = UserDefaults.standard.bool(forKey: "hasActiveSubscription")
        
        if let expiryTimestamp = UserDefaults.standard.object(forKey: "subscriptionExpiryDate") as? TimeInterval {
            subscriptionExpiryDate = Date(timeIntervalSince1970: expiryTimestamp)
            
            if let expiryDate = subscriptionExpiryDate, expiryDate > Date() {
                hasActiveSubscription = true
            } else {
                hasActiveSubscription = false
            }
        }
        
        if let tierRawValue = UserDefaults.standard.string(forKey: "currentSubscriptionTier"),
           let tier = SubscriptionTier(rawValue: tierRawValue) {
            currentSubscriptionTier = tier
        }
    }
    
    func updateSubscriptionStatus() async {
        await MainActor.run {
            isCheckingSubscription = true
        }
        
        do {
            var hasValidSubscription = false
            var latestExpiryDate: Date?
            var activeTier: SubscriptionTier?
            
            for await result in Transaction.currentEntitlements {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                if transaction.productID == SubscriptionTier.monthly.rawValue ||
                   transaction.productID == SubscriptionTier.yearly.rawValue {
                    
                    if let expirationDate = transaction.expirationDate,
                       expirationDate > Date() {
                        hasValidSubscription = true
                        
                        if latestExpiryDate == nil || expirationDate > latestExpiryDate! {
                            latestExpiryDate = expirationDate
                            activeTier = SubscriptionTier(rawValue: transaction.productID)
                        }
                    }
                }
            }
            
            await MainActor.run {
                self.hasActiveSubscription = hasValidSubscription
                self.subscriptionExpiryDate = latestExpiryDate
                self.currentSubscriptionTier = activeTier
                self.isCheckingSubscription = false
                
                UserDefaults.standard.set(hasValidSubscription, forKey: "hasActiveSubscription")
                
                if let expiryDate = latestExpiryDate {
                    UserDefaults.standard.set(expiryDate.timeIntervalSince1970, forKey: "subscriptionExpiryDate")
                }
                
                if let tier = activeTier {
                    UserDefaults.standard.set(tier.rawValue, forKey: "currentSubscriptionTier")
                }
                
                print("📱 Subscription Status - Active: \(hasValidSubscription), Tier: \(activeTier?.displayName ?? "none")")
            }
            
        } catch {
            print("❌ Failed to check subscription status: \(error)")
            
            await MainActor.run {
                self.isCheckingSubscription = false
            }
        }
    }
    
    func handleSuccessfulPurchase(productId: String) {
        if let tier = SubscriptionTier(rawValue: productId) {
            hasActiveSubscription = true
            currentSubscriptionTier = tier
            showingPaywall = false
            
            UserDefaults.standard.set(true, forKey: "hasActiveSubscription")
            UserDefaults.standard.set(tier.rawValue, forKey: "currentSubscriptionTier")
            UserDefaults.standard.set(Date(), forKey: "subscriptionPurchaseDate")
            
            purchaseCompletionHandler?(true)
            purchaseCompletionHandler = nil
            
            NotificationCenter.default.post(name: .subscriptionPurchased, object: nil)
        }
    }
    
    func handlePaywallDismissal(purchased: Bool) {
        showingPaywall = false
        
        if !purchased {
            paywallDismissedWithoutPurchase = true
            purchaseCompletionHandler?(false)
            purchaseCompletionHandler = nil
        }
    }
    
    func presentPaywall(completion: @escaping (Bool) -> Void) {
        purchaseCompletionHandler = completion
        showingPaywall = true
        completion(false)
    }
    
    func shouldShowPaywall() -> Bool {
        return !hasActiveSubscription && !isCheckingSubscription
    }
    
    func resetPaywallDismissalFlag() {
        paywallDismissedWithoutPurchase = false
    }
}

extension Notification.Name {
    static let subscriptionPurchased = Notification.Name("subscriptionPurchased")
    static let subscriptionStatusChanged = Notification.Name("subscriptionStatusChanged")
}
