import Foundation
import StoreKit
import Combine
import UIKit

@MainActor
class SimpleStoreKitManager: NSObject, ObservableObject, SKProductsRequestDelegate, @preconcurrency SKPaymentTransactionObserver {
    static let shared = SimpleStoreKitManager()
    
    // MARK: - Published Properties
    @Published var isSubscribed = false
    @Published var availableProducts: [SKProduct] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Product IDs
    private let productIDs: Set<String> = [
        "sobbrmonthly",  // $9.99/month
        "sobbryearly"    // $29.99/year
    ]
    
    // MARK: - App Store Connect Shared Secret
    // CRITICAL: Get this from App Store Connect:
    // 1. Go to App Store Connect
    // 2. Select your app
    // 3. Go to "App Information" or "Features" tab
    // 4. Find "App-Specific Shared Secret"
    // 5. Generate/copy and paste it here
    private let sharedSecret = "a150ae46ccf5456e9cf6597417deab5e"
    
    // MARK: - Private Properties
    private var productsRequest: SKProductsRequest?
    private var lastSuccessfulPurchaseTime: Date?
    private var subscriptionExpiryDate: Date?
    private var lastReceiptValidationTime: Date?
    
    override init() {
        super.init()
        
        // Check if payments are allowed
        if SKPaymentQueue.canMakePayments() {
            // Add transaction observer
            SKPaymentQueue.default().add(self)
            
            // Load products
            loadProducts()
            
            // Load cached subscription data
            loadCachedSubscriptionData()
            
            // Check if we have an active cached subscription
            if let expiryDate = subscriptionExpiryDate, expiryDate > Date() {
                print("✅ Found active cached subscription - expires: \(expiryDate)")
                isSubscribed = true
                
                // Only validate if approaching expiry (within 24 hours) or haven't validated in 24 hours
                let hoursUntilExpiry = expiryDate.timeIntervalSinceNow / 3600
                let hoursSinceLastValidation = lastReceiptValidationTime?.timeIntervalSinceNow ?? -25
                
                if hoursUntilExpiry < 24 || abs(hoursSinceLastValidation) > 24 {
                    print("🔄 Subscription approaching expiry or needs periodic validation")
                    checkSubscriptionStatus()
                }
            } else if UserDefaults.standard.bool(forKey: "hasActiveSubscription") {
                // Legacy fallback for existing users
                print("✅ Found legacy subscription flag - granting access")
                isSubscribed = true
                checkSubscriptionStatus()
            } else {
                // No cached subscription, validate receipt
                checkSubscriptionStatus()
            }
            
            // Set up periodic validation
            schedulePeriodicValidation()
        } else {
            errorMessage = "In-app purchases are disabled on this device"
        }
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    // MARK: - Product Loading
    func loadProducts() {
        guard !productIDs.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        productsRequest = SKProductsRequest(productIdentifiers: productIDs)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    // MARK: - Purchase Flow
    func purchase(_ product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else {
            errorMessage = "Purchases are not allowed on this device"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() {
        isLoading = true
        errorMessage = nil
        // Clear cache before restore to ensure fresh validation
        lastReceiptValidationTime = nil
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - Caching Methods
    private func loadCachedSubscriptionData() {
        subscriptionExpiryDate = UserDefaults.standard.object(forKey: "subscriptionExpiryDate") as? Date
        lastSuccessfulPurchaseTime = UserDefaults.standard.object(forKey: "lastSuccessfulPurchaseTime") as? Date
        lastReceiptValidationTime = UserDefaults.standard.object(forKey: "lastReceiptValidationTime") as? Date
        
        if let expiryDate = subscriptionExpiryDate {
            print("📅 Loaded cached subscription expiry: \(expiryDate)")
        }
    }
    
    private func saveCachedSubscriptionData(expiryDate: Date?) {
        subscriptionExpiryDate = expiryDate
        lastReceiptValidationTime = Date()
        
        UserDefaults.standard.set(expiryDate, forKey: "subscriptionExpiryDate")
        UserDefaults.standard.set(lastReceiptValidationTime, forKey: "lastReceiptValidationTime")
        
        if let expiryDate = expiryDate {
            print("💾 Saved subscription expiry: \(expiryDate)")
        }
    }
    
    // MARK: - Subscription Status
    private func checkSubscriptionStatus() {
        // Don't override recent successful purchases
        if let lastPurchase = lastSuccessfulPurchaseTime,
           Date().timeIntervalSince(lastPurchase) < 3600 { // 1 hour grace period
            print("✅ Skipping receipt validation - recent successful purchase within 1 hour")
            return
        }
        
        // Don't validate too frequently if we have a valid cached subscription
        if let expiryDate = subscriptionExpiryDate,
           expiryDate > Date(),
           let lastValidation = lastReceiptValidationTime,
           Date().timeIntervalSince(lastValidation) < 3600 { // Don't validate more than once per hour
            print("✅ Skipping validation - valid cached subscription and validated recently")
            return
        }
        
        validateReceipt { [weak self] (isValid, expiryDate) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Save the expiry date if we got one
                if let expiryDate = expiryDate {
                    self.saveCachedSubscriptionData(expiryDate: expiryDate)
                }
                
                // Only update subscription status if we have definitive information
                if isValid || (expiryDate != nil && expiryDate! > Date()) {
                    self.isSubscribed = true
                    UserDefaults.standard.set(true, forKey: "hasActiveSubscription")
                } else if let cachedExpiry = self.subscriptionExpiryDate, cachedExpiry > Date() {
                    // Keep subscription active if cached expiry is still valid
                    print("✅ Keeping subscription active based on cached expiry")
                    self.isSubscribed = true
                } else {
                    // Only revoke if we're certain subscription is expired
                    self.isSubscribed = false
                    UserDefaults.standard.set(false, forKey: "hasActiveSubscription")
                    self.saveCachedSubscriptionData(expiryDate: nil)
                }
            }
        }
    }
    
    // MARK: - Receipt Validation
    private func validateReceipt(completion: @escaping (Bool, Date?) -> Void) {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            print("❌ No receipt found")
            completion(false, nil)
            return
        }
        
        validateReceiptWithApple(receiptData: receiptData) { isValid, expiryDate in
            completion(isValid, expiryDate)
        }
    }
    
    private func validateReceiptWithApple(receiptData: Data, completion: @escaping (Bool, Date?) -> Void) {
        let receiptString = receiptData.base64EncodedString()
        let requestData: [String: Any] = [
            "receipt-data": receiptString,
            "password": sharedSecret, // Uses the shared secret defined above
            "exclude-old-transactions": true
        ]
        
        // Try sandbox first (for development/testing)
        validateReceiptWithURL(requestData: requestData, isSandbox: true) { [weak self] (isValid, expiryDate, shouldRetryProduction) in
            if isValid || expiryDate != nil {
                completion(isValid, expiryDate)
            } else if shouldRetryProduction {
                // Retry with production URL
                self?.validateReceiptWithURL(requestData: requestData, isSandbox: false) { (isValid, expiryDate, _) in
                    completion(isValid, expiryDate)
                }
            } else {
                completion(false, nil)
            }
        }
    }
    
    private func validateReceiptWithURL(requestData: [String: Any], isSandbox: Bool, completion: @escaping (Bool, Date?, Bool) -> Void) {
        let urlString = isSandbox ? "https://sandbox.itunes.apple.com/verifyReceipt" : "https://buy.itunes.apple.com/verifyReceipt"
        let validationURL = URL(string: urlString)!
        
        print("🔄 Trying \(isSandbox ? "sandbox" : "production") receipt validation...")
        
        var request = URLRequest(url: validationURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
        } catch {
            print("❌ Failed to serialize receipt data: \(error)")
            completion(false, nil, false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                print("❌ Receipt validation network error: \(error?.localizedDescription ?? "Unknown")")
                completion(false, nil, false)
                return
            }
            
            Task { @MainActor in
                self.parseReceiptResponseWithRetry(data: data, isSandbox: isSandbox, completion: completion)
            }
        }.resume()
    }
    
    private func parseReceiptResponseWithRetry(data: Data, isSandbox: Bool, completion: @escaping (Bool, Date?, Bool) -> Void) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(false, nil, false)
                return
            }
            
            guard let status = json["status"] as? Int else {
                completion(false, nil, false)
                return
            }
            
            print("📋 Receipt validation status: \(status) (\(isSandbox ? "sandbox" : "production"))")
            
            // Log additional error info for debugging
            if status != 0 {
                if let exception = json["exception"] as? String {
                    print("❌ Exception: \(exception)")
                }
                if let errorMessage = json["error"] as? String {
                    print("❌ Error: \(errorMessage)")
                }
            }
            
            switch status {
            case 0:
                // Success - parse the receipt
                parseReceiptData(json: json, completion: { (isValid, expiryDate) in
                    completion(isValid, expiryDate, false)
                })
            case 21007:
                // Sandbox receipt sent to production - retry with sandbox
                print("🔄 Status 21007: Sandbox receipt sent to production")
                completion(false, nil, !isSandbox) // Retry with sandbox if we tried production
            case 21008:
                // Production receipt sent to sandbox - retry with production  
                print("🔄 Status 21008: Production receipt sent to sandbox")
                completion(false, nil, isSandbox) // Retry with production if we tried sandbox
            case 21002:
                print("❌ Status 21002: Receipt data is malformed")
                completion(false, nil, false)
            case 21003:
                print("❌ Status 21003: Receipt could not be authenticated")
                completion(false, nil, false)
            case 21004:
                print("❌ Status 21004: Shared secret does not match")
                completion(false, nil, false)
            case 21005:
                print("❌ Status 21005: Receipt server is not available")
                completion(false, nil, false)
            case 21006:
                print("❌ Status 21006: Receipt is valid but subscription has expired")
                // This is actually not an error - parse the receipt to get expiry date
                parseReceiptData(json: json, completion: { (_, expiryDate) in
                    completion(false, expiryDate, false)
                })
            default:
                // Other error
                print("❌ Receipt validation failed with unknown status: \(status)")
                completion(false, nil, false)
            }
            
        } catch {
            print("❌ Failed to parse receipt response: \(error)")
            completion(false, nil, false)
        }
    }
    
    private func parseReceiptData(json: [String: Any], completion: @escaping (Bool, Date?) -> Void) {
        // First check for latest_receipt_info (for auto-renewable subscriptions)
        let transactions: [[String: Any]]
        if let latestReceiptInfo = json["latest_receipt_info"] as? [[String: Any]], !latestReceiptInfo.isEmpty {
            print("📋 Using latest_receipt_info with \(latestReceiptInfo.count) transactions")
            transactions = latestReceiptInfo
        } else if let receipt = json["receipt"] as? [String: Any],
                  let inApp = receipt["in_app"] as? [[String: Any]] {
            print("📋 Using receipt.in_app with \(inApp.count) transactions")
            transactions = inApp
        } else {
            print("❌ No transactions found in receipt")
            completion(false, nil)
            return
        }
        
        var latestExpiryDate: Date?
        var hasActiveSubscription = false
        
        // Find the latest subscription expiry date
        for transaction in transactions {
            guard let productId = transaction["product_id"] as? String,
                  productIDs.contains(productId) else {
                continue
            }
            
            // Try multiple date formats
            var expiresDate: Date?
            
            // First try expires_date_ms (most accurate, in milliseconds)
            if let expiresDateMs = transaction["expires_date_ms"] as? String,
               let expiresDateMsDouble = Double(expiresDateMs) {
                expiresDate = Date(timeIntervalSince1970: expiresDateMsDouble / 1000.0)
                print("📅 Found expires_date_ms: \(expiresDate!)")
            }
            // Also check if expires_date_ms is already a number
            else if let expiresDateMsNum = transaction["expires_date_ms"] as? Double {
                expiresDate = Date(timeIntervalSince1970: expiresDateMsNum / 1000.0)
                print("📅 Found expires_date_ms (number): \(expiresDate!)")
            }
            // Try expires_date as RFC 3339 formatted string
            else if let expiresDateString = transaction["expires_date"] as? String {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: expiresDateString) {
                    expiresDate = date
                    print("📅 Found expires_date (RFC3339): \(expiresDate!)")
                }
            }
            
            if let expiresDate = expiresDate {
                // Update latest expiry date
                if latestExpiryDate == nil || expiresDate > latestExpiryDate! {
                    latestExpiryDate = expiresDate
                }
                
                // Check if subscription is active (with 5 minute grace for clock differences)
                let gracePeriod: TimeInterval = 300 // 5 minutes
                let isActive = expiresDate.timeIntervalSinceNow > -gracePeriod
                
                if isActive {
                    hasActiveSubscription = true
                    print("✅ Active subscription found: \(productId), expires: \(expiresDate)")
                } else {
                    print("❌ Expired subscription found: \(productId), expired: \(expiresDate)")
                }
            }
        }
        
        if !hasActiveSubscription && latestExpiryDate == nil {
            print("⚠️ No active subscriptions found from \(transactions.count) transactions")
        }
        
        completion(hasActiveSubscription, latestExpiryDate)
    }
    
    
    private func updateSubscriptionStatus(_ isActive: Bool) {
        isSubscribed = isActive
        UserDefaults.standard.set(isActive, forKey: "hasActiveSubscription")
        
        // Post notification
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .subscriptionStatusChanged,
                object: nil,
                userInfo: ["isActive": isActive]
            )
        }
    }
    
    // MARK: - Public Methods for Periodic Checks
    func refreshSubscriptionStatus() {
        checkSubscriptionStatus()
    }
    
    // Force refresh subscription (for debugging or after restore)
    func forceRefreshSubscriptionStatus() {
        print("🔄 Force refreshing subscription status...")
        lastReceiptValidationTime = nil // Clear last validation time to force refresh
        checkSubscriptionStatus()
    }
    
    // Clear all cached subscription data (for debugging)
    func clearSubscriptionCache() {
        print("🗑 Clearing subscription cache...")
        subscriptionExpiryDate = nil
        lastSuccessfulPurchaseTime = nil
        lastReceiptValidationTime = nil
        UserDefaults.standard.removeObject(forKey: "subscriptionExpiryDate")
        UserDefaults.standard.removeObject(forKey: "lastSuccessfulPurchaseTime")
        UserDefaults.standard.removeObject(forKey: "lastReceiptValidationTime")
        UserDefaults.standard.removeObject(forKey: "hasActiveSubscription")
        isSubscribed = false
    }
    
    func schedulePeriodicValidation() {
        // Validate subscription when app becomes active, but with smart caching
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            
            // Only refresh if:
            // 1. No cached expiry date
            // 2. Cached expiry is approaching (within 24 hours)
            // 3. Haven't validated in the last hour
            
            let shouldRefresh: Bool
            if let expiryDate = self.subscriptionExpiryDate {
                let hoursUntilExpiry = expiryDate.timeIntervalSinceNow / 3600
                let hoursSinceLastValidation = self.lastReceiptValidationTime?.timeIntervalSinceNow ?? -25
                shouldRefresh = hoursUntilExpiry < 24 || abs(hoursSinceLastValidation) > 1
            } else {
                shouldRefresh = true
            }
            
            if shouldRefresh {
                self.refreshSubscriptionStatus()
            } else {
                print("✅ Skipping refresh - valid cached subscription")
            }
        }
    }
    
    // MARK: - Helper Methods
    func monthlyProduct() -> SKProduct? {
        return availableProducts.first { $0.productIdentifier == "sobbrmonthly" }
    }
    
    func yearlyProduct() -> SKProduct? {
        return availableProducts.first { $0.productIdentifier == "sobbryearly" }
    }
    
    func formattedPrice(for product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? "$0.00"
    }
    
    func calculateSavings() -> String {
        guard let monthly = monthlyProduct(),
              let yearly = yearlyProduct() else { return "0%" }
        
        let monthlyAnnualCost = monthly.price.doubleValue * 12
        let yearlyCost = yearly.price.doubleValue
        let savings = (monthlyAnnualCost - yearlyCost) / monthlyAnnualCost
        
        return "\(Int(savings * 100))%"
    }
}

// MARK: - SKProductsRequestDelegate
extension SimpleStoreKitManager {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.availableProducts = response.products.sorted { product1, product2 in
                // Sort by price, monthly first
                if product1.productIdentifier == "sobbrmonthly" { return true }
                if product2.productIdentifier == "sobbrmonthly" { return false }
                return product1.price.doubleValue < product2.price.doubleValue
            }
            
            self.isLoading = false
            
            if response.invalidProductIdentifiers.count > 0 {
                print("⚠️ Invalid product identifiers: \(response.invalidProductIdentifiers)")
            }
            
            print("✅ Loaded \(response.products.count) products")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Failed to load products: \(error.localizedDescription)"
            self.isLoading = false
        }
        print("❌ Products request failed: \(error)")
    }
}

// MARK: - SKPaymentTransactionObserver
extension SimpleStoreKitManager {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                print("⏳ Purchase in progress...")
                
            case .purchased:
                print("✅ Purchase successful: \(transaction.payment.productIdentifier)")
                completeTransaction(transaction)
                
            case .restored:
                print("✅ Purchase restored: \(transaction.payment.productIdentifier)")
                completeTransaction(transaction)
                
            case .failed:
                print("❌ Purchase failed: \(transaction.error?.localizedDescription ?? "Unknown error")")
                failedTransaction(transaction)
                
            case .deferred:
                print("⏳ Purchase deferred (parental approval required)")
                
            @unknown default:
                break
            }
        }
    }
    
    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = nil
        }
        
        // After successful transaction, grant access immediately
        let productId = transaction.payment.productIdentifier
        if productIDs.contains(productId) {
            print("✅ Granting access for valid subscription product: \(productId)")
            lastSuccessfulPurchaseTime = Date()
            UserDefaults.standard.set(lastSuccessfulPurchaseTime, forKey: "lastSuccessfulPurchaseTime")
            
            // Calculate approximate expiry date based on product type
            var estimatedExpiryDate: Date?
            if productId == "sobbrmonthly" {
                estimatedExpiryDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
            } else if productId == "sobbryearly" {
                estimatedExpiryDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
            }
            
            // Save estimated expiry immediately
            if let expiryDate = estimatedExpiryDate {
                saveCachedSubscriptionData(expiryDate: expiryDate)
            }
            
            DispatchQueue.main.async {
                self.updateSubscriptionStatus(true)
            }
        }
        
        // Validate receipt to get accurate expiry date
        validateReceipt { [weak self] (isValid, expiryDate) in
            if let expiryDate = expiryDate {
                // Update with accurate expiry date from receipt
                self?.saveCachedSubscriptionData(expiryDate: expiryDate)
                print("✅ Updated with accurate expiry date: \(expiryDate)")
            } else if !isValid {
                print("⚠️ Receipt validation failed after successful purchase - keeping estimated expiry")
            }
        }
        
        // Finish the transaction
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func failedTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            if let error = transaction.error as? SKError {
                switch error.code {
                case .paymentCancelled:
                    self.errorMessage = nil // User cancelled, don't show error
                case .paymentNotAllowed:
                    self.errorMessage = "Payments are not allowed on this device"
                case .storeProductNotAvailable:
                    self.errorMessage = "Product is not available"
                case .cloudServiceNetworkConnectionFailed:
                    self.errorMessage = "Network error occurred"
                default:
                    self.errorMessage = "Purchase failed: \(error.localizedDescription)"
                }
            } else {
                self.errorMessage = "Purchase failed"
            }
            
            self.isLoading = false
        }
        
        // Finish the transaction
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DispatchQueue.main.async {
            self.isLoading = false
        }
        
        // Check if any restored transactions are for our subscription products
        let hasSubscriptionTransaction = queue.transactions.contains { transaction in
            self.productIDs.contains(transaction.payment.productIdentifier) && 
            transaction.transactionState == .purchased
        }
        
        if hasSubscriptionTransaction {
            print("✅ Found subscription transaction in restore - granting access")
            DispatchQueue.main.async {
                self.updateSubscriptionStatus(true)
                self.errorMessage = nil
            }
        } else {
            // Try receipt validation as fallback
            validateReceipt { [weak self] (isValid, expiryDate) in
                DispatchQueue.main.async {
                    if isValid || (expiryDate != nil && expiryDate! > Date()) {
                        if let expiryDate = expiryDate {
                            self?.saveCachedSubscriptionData(expiryDate: expiryDate)
                        }
                        self?.updateSubscriptionStatus(true)
                        self?.errorMessage = nil
                    } else {
                        self?.errorMessage = "No active subscriptions found"
                    }
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}

// MARK: - Notification Extensions (if not already defined)
extension Notification.Name {
    static let subscriptionStatusChanged = Notification.Name("subscriptionStatusChanged")
    static let subscriptionPurchased = Notification.Name("subscriptionPurchased")
}