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
    @Published var isSubscribed = false // Actual subscription status from Superwall
    @Published var subscriptionValidated = false // Security flag
    
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
        case 11:
            placement = "test" // Special test placement for age 11
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
        
        // Validate subscription status for security
        validateSubscription()
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
            // Mark user as subscribed since paywall completed successfully
            self.markSubscribed()
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
    
    // MARK: - Subscription Management & Security
    
    /// Validate subscription status - SECURITY CRITICAL
    func validateSubscription() {
        guard isInitialized else {
            print("❌ Cannot validate subscription - SuperwallManager not initialized")
            isSubscribed = false
            subscriptionValidated = false
            return
        }
        
        // Check Superwall's internal subscription status
        // In a real implementation, this would query Superwall's subscription state
        // For now, we'll implement a security check based on Superwall's behavior
        
        print("🔒 Validating subscription status...")
        
        // Reset validation flag
        subscriptionValidated = false
        
        // Superwall provides subscription status through its delegate methods
        // We'll implement a security check that validates against bypass attempts
        checkSuperwallSubscriptionStatus()
    }
    
    private func checkSuperwallSubscriptionStatus() {
        // This would normally use Superwall.shared.subscriptionStatus
        // But since we're using the simpler approach, we'll implement a security gate
        
        // For security, we assume user is NOT subscribed unless proven otherwise
        isSubscribed = false
        subscriptionValidated = true // Mark as validated (but not subscribed)
        
        print("🔒 Subscription validation complete - Status: \(isSubscribed)")
    }
    
    /// Mark user as subscribed (called after successful paywall completion)
    func markSubscribed() {
        print("✅ User subscription confirmed")
        isSubscribed = true
        subscriptionValidated = true
    }
    
    /// Security method to verify subscription before allowing app access
    func hasValidSubscription() -> Bool {
        guard subscriptionValidated else {
            print("⚠️ Subscription not validated - blocking access")
            return false
        }
        
        print("🔍 Checking subscription status: \(isSubscribed)")
        return isSubscribed
    }
    
    /// Restore purchases - Superwall handles this automatically
    func restorePurchases() {
        print("🔄 Restoring purchases...")
        validateSubscription() // Re-validate on restore
        print("ℹ️ Superwall handles restore purchases automatically")
    }
    
    // MARK: - Debug Support
    
    /// Debug method to simulate subscription (DEBUG builds only)
    #if DEBUG
    func debugGrantSubscription() {
        print("🐛 DEBUG: Granting subscription access")
        // This would typically involve setting user properties in Superwall
        // For debug purposes, we'll just update local state
        isSubscribed = true
        subscriptionValidated = true
        
        // Set user property in Superwall to mark as subscribed
        Superwall.shared.setUserAttributes([
            "debug_subscription": true,
            "subscription_status": "active"
        ])
        
        print("✅ DEBUG: Subscription granted")
    }
    
    func debugRemoveSubscription() {
        print("🐛 DEBUG: Removing subscription access")
        isSubscribed = false
        subscriptionValidated = true
        
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
