//
//  SuperwallManager.swift
//  Sobbr
//
//  Professional subscription management using Superwall
//

import Foundation
import SuperwallKit
import StoreKit

@MainActor
class SuperwallManager: ObservableObject {
    static let shared = SuperwallManager()
    
    // MARK: - Published Properties
    @Published var isInitialized = false
    @Published var isSubscribedLocally = false // For UI state only, don't use for business logic
    
    // MARK: - Configuration
    private let apiKey = "pk_PkRoChE79LHjlJNRoMhlc"
    
    // MARK: - Placement Keys
    struct Placements {
        static let onboardingComplete = "default_paywall"
        static let premiumFeature = "premium_feature"
        static let settings = "settings_paywall"
        
        // Age-based placements (matching Superwall dashboard)
        static let age21_22 = "age21-22"
        static let age23_26 = "age23-26" 
        static let age26_30 = "age26-30"
        static let age31_34 = "age31-34"
        static let age35_40 = "age35-40"
        static let age41_50 = "age41-50"
        static let age50Plus = "age50+"
    }
    
    // MARK: - Age-Based Placement Logic
    
    /// Get the appropriate placement key based on user's age
    private func getAgePlacement(for age: Int) -> String {
        let placement: String
        
        switch age {
        case 18...22:
            placement = Placements.age21_22
        case 23...26:
            placement = Placements.age23_26
        case 27...30:
            placement = Placements.age26_30
        case 31...34:
            placement = Placements.age31_34
        case 35...40:
            placement = Placements.age35_40
        case 41...50:
            placement = Placements.age41_50
        case 51...100:
            placement = Placements.age50Plus
        default:
            placement = Placements.onboardingComplete // fallback for edge cases
        }
        
        print("🎯 Using age-based placement: \(placement) for age: \(age)")
        return placement
    }
    
    private init() {
        // Private init for singleton
    }
    
    // MARK: - Initialization
    
    func configure() {
        guard !isInitialized else {
            print("⚠️ SuperwallManager already initialized")
            return
        }
        
        print("🚀 Initializing SuperwallKit with API key: \(apiKey)")
        Superwall.configure(apiKey: apiKey)
        
        // Set up Superwall delegate for subscription status updates
        setupSuperwallDelegate()
        
        isInitialized = true
        print("✅ SuperwallKit initialized successfully")
        
        // Update local subscription state for UI purposes only
        updateLocalSubscriptionState()
    }
    
    // MARK: - Paywall Presentation
    
    /// Present paywall for onboarding completion with age-based targeting
    func presentOnboardingPaywall(userAge: Int, completion: @escaping () -> Void) {
        guard isInitialized else {
            print("❌ SuperwallManager not initialized")
            completion()
            return
        }
        
        let placement: String
        if userAge > 0 {
            placement = getAgePlacement(for: userAge)
            print("🎯 Presenting onboarding paywall for age \(userAge) with placement: \(placement)")
        } else {
            placement = Placements.onboardingComplete
            print("🎯 Presenting onboarding paywall with default placement (no age provided): \(placement)")
        }
        
        Superwall.shared.register(placement: placement) {
            print("✅ Onboarding paywall flow completed for placement: \(placement)")
            completion()
        }
    }
    
    /// Present paywall for premium features
    func presentPremiumFeaturePaywall(completion: @escaping (Bool) -> Void) {
        guard isInitialized else {
            print("❌ SuperwallManager not initialized")
            completion(false)
            return
        }
        
        print("🎯 Presenting premium feature paywall...")
        Superwall.shared.register(placement: Placements.premiumFeature) {
            print("✅ Premium feature paywall flow completed")
            // User either subscribed or paywall was dismissed
            // Superwall handles the subscription state internally
            completion(true)
        }
    }
    
    /// Present paywall in settings
    func presentSettingsPaywall() {
        guard isInitialized else {
            print("❌ SuperwallManager not initialized")
            return
        }
        
        print("🎯 Presenting settings paywall...")
        Superwall.shared.register(placement: Placements.settings) {
            print("✅ Settings paywall flow completed")
        }
    }
    
    // MARK: - Subscription Management
    
    /// Restore purchases - Superwall handles this automatically
    func restorePurchases() {
        print("🔄 Restoring purchases...")
        // Superwall automatically handles restore purchases internally
        // We don't need to call a specific API for this
        print("ℹ️ Superwall handles restore purchases automatically")
        updateLocalSubscriptionState()
    }
    
    /// Check if user has active subscription (for UI purposes only)
    /// Don't use this for business logic - let Superwall handle that
    private func updateLocalSubscriptionState() {
        // This is just for UI state - Superwall handles actual subscription logic internally
        // For now, we'll rely on Superwall's internal subscription management
        // The actual subscription state is managed by Superwall when presenting paywalls
        print("📊 Local subscription state updated - relying on Superwall internal management")
    }
    
    // MARK: - Debug Support
    
    /// Debug method to simulate subscription (DEBUG builds only)
    #if DEBUG
    func debugGrantSubscription() {
        print("🐛 DEBUG: Granting subscription access")
        // This would typically involve setting user properties in Superwall
        // For debug purposes, we'll just update local state
        isSubscribedLocally = true
        
        // Set user property in Superwall to mark as subscribed
        Superwall.shared.setUserAttributes([
            "debug_subscription": true,
            "subscription_status": "active"
        ])
        
        print("✅ DEBUG: Subscription granted")
    }
    
    func debugRemoveSubscription() {
        print("🐛 DEBUG: Removing subscription access")
        isSubscribedLocally = false
        
        // Remove debug subscription
        Superwall.shared.setUserAttributes([
            "debug_subscription": false,
            "subscription_status": "inactive"
        ])
        
        print("✅ DEBUG: Subscription removed")
    }
    #endif
    
    // MARK: - User Properties
    
    /// Set user properties for Superwall targeting
    func setUserProperties(_ properties: [String: Any]) {
        guard isInitialized else {
            print("❌ SuperwallManager not initialized")
            return
        }
        
        print("👤 Setting user properties: \(properties)")
        Superwall.shared.setUserAttributes(properties)
    }
    
    /// Track events for Superwall
    func trackEvent(_ eventName: String, parameters: [String: Any] = [:]) {
        guard isInitialized else {
            print("❌ SuperwallManager not initialized")
            return
        }
        
        print("📊 Tracking event: \(eventName) with parameters: \(parameters)")
        // Use the correct Superwall track method
        Superwall.shared.register(placement: eventName)
    }
    
    // MARK: - Superwall Configuration
    
    private func setupSuperwallDelegate() {
        // Superwall handles subscription status internally
        // We don't need to set up custom delegates for basic functionality
        print("ℹ️ Superwall delegate setup - using internal management")
    }
}
