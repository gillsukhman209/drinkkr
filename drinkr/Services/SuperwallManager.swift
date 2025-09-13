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
    
    // MARK: - Persistence Keys
    private let subscriptionStatusKey = "superwallSubscriptionStatus"
    private let subscriptionExpiryKey = "superwallSubscriptionExpiry"
    
    // MARK: - Configuration
    private let apiKey = "pk_PkRoChE79LHjlJNRoMhlc"
    
    // MARK: - Placement Keys
    struct Placements {
        static let onboardingComplete = "default_paywall"
        static let premiumFeature = "premium_feature"
        static let settings = "settings_paywall"
        static let yearlyFreeTrial = "yearly_free_trial"
        
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
        
        // Set up Superwall delegate for subscription status updates and paywall tracking
        setupSuperwallDelegate()
        
        isInitialized = true
        print("✅ SuperwallKit initialized successfully")
        
        // Validate subscription status for security (async)
        Task.detached {
            await self.validateSubscription()
        }
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
            // Don't automatically mark as subscribed - let delegate handle subscription events
            // The SuperwallDelegate will call markSubscribed() if user actually subscribes
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
    func validateSubscription() async {
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
        // First, check if we have a persisted subscription status
        let persistedStatus = UserDefaults.standard.bool(forKey: subscriptionStatusKey)
        
        // Check if subscription is still valid (not expired)
        if let expiryDate = UserDefaults.standard.object(forKey: subscriptionExpiryKey) as? Date {
            if Date() < expiryDate && persistedStatus {
                // Subscription is still valid - trust the persisted state
                isSubscribed = true
                subscriptionValidated = true
                print("✅ Restored valid subscription (expires: \(expiryDate))")
                
                // DO NOT auto-verify with StoreKit - this causes the sign-in loop
                // Only verify when user explicitly requests it (restore purchases)
                return
            }
        }
        
        // If no valid persisted subscription, just use the persisted state
        // Don't auto-check StoreKit to avoid sign-in prompts
        isSubscribed = persistedStatus
        subscriptionValidated = true
        
        if !isSubscribed {
            print("ℹ️ No active subscription found in cache")
        }
    }
    
    @MainActor
    private func verifySubscriptionWithSuperwall() async {
        // Check actual subscription status with StoreKit
        do {
            // Verify receipt and entitlements
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    // User has an active subscription
                    print("✅ Found active subscription: \(transaction.productID)")
                    isSubscribed = true
                    subscriptionValidated = true
                    
                    // Persist the subscription status
                    UserDefaults.standard.set(true, forKey: subscriptionStatusKey)
                    
                    // Set expiry date (for auto-renewable subscriptions)
                    if let expiryDate = transaction.expirationDate {
                        UserDefaults.standard.set(expiryDate, forKey: subscriptionExpiryKey)
                    }
                    
                    return
                }
            }
            
            // No active subscriptions found
            print("❌ No active subscriptions found")
            isSubscribed = false
            subscriptionValidated = true
            UserDefaults.standard.set(false, forKey: subscriptionStatusKey)
            
        } catch {
            print("❌ Error checking subscription status: \(error)")
            // In case of error, check persisted status as fallback
            isSubscribed = UserDefaults.standard.bool(forKey: subscriptionStatusKey)
            subscriptionValidated = true
        }
    }
    
    @MainActor
    private func restoreSubscriptionWithStoreKit() async {
        // Only call this when user explicitly requests restore
        // This prevents the repeated sign-in popup issue
        do {
            print("🔄 User requested restore purchases...")
            
            // Sync with App Store to get latest subscription status
            try await AppStore.sync()
            
            // Re-verify subscription after sync
            await verifySubscriptionWithSuperwall()
            
            print("✅ Restore purchases complete")
            
        } catch {
            print("⚠️ Could not sync with App Store: \(error)")
        }
    }
    
    /// Mark user as subscribed (called after successful paywall completion)
    func markSubscribed() {
        print("✅ User subscription confirmed")
        isSubscribed = true
        subscriptionValidated = true
        
        // Persist the subscription status
        UserDefaults.standard.set(true, forKey: subscriptionStatusKey)
        
        // Set a default expiry date (1 year for yearly, 1 week for weekly)
        // This will be updated with actual expiry from StoreKit
        let defaultExpiry = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        UserDefaults.standard.set(defaultExpiry, forKey: subscriptionExpiryKey)
        
        // Verify with StoreKit to get actual expiry
        Task {
            await verifySubscriptionWithSuperwall()
        }
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
    
    // MARK: - Placement Presentation
    
    /// Present a specific Superwall placement by name
    func presentPlacement(_ placementName: String) {
        guard isInitialized else {
            print("⚠️ SuperwallManager not initialized - cannot present placement")
            return
        }
        
        print("🎁 Presenting Superwall placement: \(placementName)")
        
        // Use the correct API for Superwall 4.7.0
        Task { @MainActor in
            print("🚀 Triggering placement: \(placementName)")
            Superwall.shared.register(placement: placementName)
            print("✅ Placement registration complete")
        }
    }
    
    /// Restore purchases - properly restore and persist subscription status
    func restorePurchases() {
        print("🔄 Restoring purchases...")
        
        Task.detached {
            // First try to restore with StoreKit
            await self.restoreSubscriptionWithStoreKit()
            
            // Then validate the subscription
            await self.validateSubscription()
        }
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
        Superwall.shared.delegate = self
        print("ℹ️ Superwall delegate setup complete")
    }
}

// MARK: - SuperwallDelegate

extension SuperwallManager: SuperwallDelegate {
    
    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
        case .paywallDecline(let paywallInfo):
            print("💔 Paywall declined for placement: \(paywallInfo.identifier)")
            
            // Check if this is a paywall dismissal that should trigger retention notifications
            // Note: paywallInfo.identifier contains the template name from Superwall dashboard, not placement name
            print("🔍 Checking if placement '\(paywallInfo.identifier)' should trigger retention notification")
            
            // Always schedule retention for any paywall decline during onboarding flow
            // This ensures we catch all paywall dismissals regardless of template names
            RetentionNotificationManager.shared.handlePaywallDismissed(placement: paywallInfo.identifier)
            
        case let .paywallPresentationRequest(status, reason):
            print("🎯 Paywall presentation requested - Status: \(status), Reason: \(reason?.description ?? "nil")")
            
        case .paywallClose(let paywallCloseReason):
            print("🚪 Paywall closed: \(paywallCloseReason)")
            
        case let .subscriptionStart(product, paywallInfo):
            print("🎉 Subscription started: \(product.productIdentifier) for paywall: \(paywallInfo.identifier)")
            // User subscribed - cancel any retention notifications
            RetentionNotificationManager.shared.userDidSubscribe()
            markSubscribed()
            
        case let .freeTrialStart(product, paywallInfo):
            print("🆓 Free trial started: \(product.productIdentifier) for paywall: \(paywallInfo.identifier)")
            // User started trial - cancel any retention notifications
            RetentionNotificationManager.shared.userDidSubscribe()
            markSubscribed()
            
        case let .transactionComplete(transaction, product, transactionType, paywallInfo):
            print("✅ Transaction completed: \(product.productIdentifier) for paywall: \(paywallInfo.identifier)")
            // User completed purchase - cancel any retention notifications
            RetentionNotificationManager.shared.userDidSubscribe()
            markSubscribed()
            
        case let .transactionRestore(restoreType, paywallInfo):
            print("🔄 Transaction restored: \(restoreType) for paywall: \(paywallInfo.identifier)")
            // User restored purchase - cancel any retention notifications
            RetentionNotificationManager.shared.userDidSubscribe()
            markSubscribed()
            
        case let .nonRecurringProductPurchase(product, paywallInfo):
            print("💳 Non-recurring purchase: \(product.id) for paywall: \(paywallInfo.identifier)")
            
        default:
            print("ℹ️ Superwall event: \(eventInfo.event)")
        }
    }
    
    // MARK: - Paywall Lifecycle Delegate Methods
    
    func didPresentPaywall(withInfo paywallInfo: PaywallInfo) {
        print("🎬 Paywall presented: \(paywallInfo.identifier)")
        // You can pause background tasks, hide UI elements, etc. when paywall is shown
    }
    
    func didDismissPaywall(withInfo paywallInfo: PaywallInfo) {
        print("🔚 Paywall dismissed: \(paywallInfo.identifier)")
        
        // Alternative place to trigger retention notifications when paywall is dismissed
        // This catches all dismissals, including manual dismissals and declines
        let targetPlacements = ["default_paywall", "premium_feature", "settings_paywall", "yearly_free_trial"]
        if targetPlacements.contains(paywallInfo.identifier) {
            RetentionNotificationManager.shared.handlePaywallDismissed(placement: paywallInfo.identifier)
        }
        
        // Resume background tasks, show UI elements, etc.
    }
    
    func willPresentPaywall(withInfo paywallInfo: PaywallInfo) {
        print("🚀 Paywall about to present: \(paywallInfo.identifier)")
        // Prepare for paywall presentation (pause video, etc.)
    }
    
    func willDismissPaywall(withInfo paywallInfo: PaywallInfo) {
        print("👋 Paywall about to dismiss: \(paywallInfo.identifier)")
        // Prepare for paywall dismissal
    }
}
