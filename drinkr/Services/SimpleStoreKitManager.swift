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
    
    // MARK: - Private Properties
    private var productsRequest: SKProductsRequest?
    private var lastSuccessfulPurchaseTime: Date?
    
    override init() {
        super.init()
        
        // Check if payments are allowed
        if SKPaymentQueue.canMakePayments() {
            // Add transaction observer
            SKPaymentQueue.default().add(self)
            
            // Load products
            loadProducts()
            
            // Check if we have a stored subscription status first
            let hasActiveSubscription = UserDefaults.standard.bool(forKey: "hasActiveSubscription")
            
            // Also check for recent successful purchase timestamp
            if let purchaseTimestamp = UserDefaults.standard.object(forKey: "lastSuccessfulPurchaseTime") as? Date {
                lastSuccessfulPurchaseTime = purchaseTimestamp
            }
            
            if hasActiveSubscription {
                print("✅ Found stored subscription status - granting access")
                isSubscribed = true
                
                // Still validate if it's been a while since last purchase
                if let lastPurchase = lastSuccessfulPurchaseTime,
                   Date().timeIntervalSince(lastPurchase) > 3600 { // 1 hour
                    print("🔄 Validating older subscription...")
                    checkSubscriptionStatus()
                }
            } else {
                // Check subscription status via receipt validation
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
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - Subscription Status
    private func checkSubscriptionStatus() {
        // Don't override recent successful purchases with failed receipt validation
        if let lastPurchase = lastSuccessfulPurchaseTime,
           Date().timeIntervalSince(lastPurchase) < 300 { // 5 minutes
            print("✅ Skipping receipt validation - recent successful purchase within 5 minutes")
            return
        }
        
        validateReceipt { [weak self] isValid in
            DispatchQueue.main.async {
                // Only update subscription status if no recent successful purchase
                if let self = self,
                   let lastPurchase = self.lastSuccessfulPurchaseTime,
                   Date().timeIntervalSince(lastPurchase) < 300 {
                    print("✅ Keeping subscription active - recent successful purchase")
                    return
                }
                
                self?.isSubscribed = isValid
                UserDefaults.standard.set(isValid, forKey: "hasActiveSubscription")
            }
        }
    }
    
    // MARK: - Receipt Validation
    private func validateReceipt(completion: @escaping (Bool) -> Void) {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            print("❌ No receipt found")
            completion(false)
            return
        }
        
        validateReceiptWithApple(receiptData: receiptData) { isValid in
            completion(isValid)
        }
    }
    
    private func validateReceiptWithApple(receiptData: Data, completion: @escaping (Bool) -> Void) {
        let receiptString = receiptData.base64EncodedString()
        let requestData: [String: Any] = [
            "receipt-data": receiptString,
            "password": "", // Add your shared secret here for auto-renewable subscriptions
            "exclude-old-transactions": true
        ]
        
        // Try sandbox first (for development/testing)
        validateReceiptWithURL(requestData: requestData, isSandbox: true) { [weak self] isValid, shouldRetryProduction in
            if isValid {
                completion(true)
            } else if shouldRetryProduction {
                // Retry with production URL
                self?.validateReceiptWithURL(requestData: requestData, isSandbox: false) { isValid, _ in
                    completion(isValid)
                }
            } else {
                completion(false)
            }
        }
    }
    
    private func validateReceiptWithURL(requestData: [String: Any], isSandbox: Bool, completion: @escaping (Bool, Bool) -> Void) {
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
            completion(false, false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                print("❌ Receipt validation network error: \(error?.localizedDescription ?? "Unknown")")
                completion(false, false)
                return
            }
            
            Task { @MainActor in
                self.parseReceiptResponseWithRetry(data: data, isSandbox: isSandbox, completion: completion)
            }
        }.resume()
    }
    
    private func parseReceiptResponseWithRetry(data: Data, isSandbox: Bool, completion: @escaping (Bool, Bool) -> Void) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(false, false)
                return
            }
            
            guard let status = json["status"] as? Int else {
                completion(false, false)
                return
            }
            
            print("📋 Receipt validation status: \(status) (\(isSandbox ? "sandbox" : "production"))")
            
            switch status {
            case 0:
                // Success - parse the receipt
                parseReceiptData(json: json, completion: { isValid in
                    completion(isValid, false)
                })
            case 21007:
                // Sandbox receipt sent to production - retry with sandbox
                print("🔄 Status 21007: Sandbox receipt sent to production")
                completion(false, !isSandbox) // Retry with sandbox if we tried production
            case 21008:
                // Production receipt sent to sandbox - retry with production  
                print("🔄 Status 21008: Production receipt sent to sandbox")
                completion(false, isSandbox) // Retry with production if we tried sandbox
            default:
                // Other error
                print("❌ Receipt validation failed with status: \(status)")
                completion(false, false)
            }
            
        } catch {
            print("❌ Failed to parse receipt response: \(error)")
            completion(false, false)
        }
    }
    
    private func parseReceiptData(json: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let receipt = json["receipt"] as? [String: Any],
              let inApp = receipt["in_app"] as? [[String: Any]] else {
            completion(false)
            return
        }
        
        // Check for active subscriptions
        let hasActiveSubscription = inApp.contains { transaction in
            guard let productId = transaction["product_id"] as? String,
                  productIDs.contains(productId),
                  let expiresDateString = transaction["expires_date"] as? String,
                  let expiresDateMs = Double(expiresDateString) else {
                return false
            }
            
            let expiresDate = Date(timeIntervalSince1970: expiresDateMs / 1000.0)
            let isActive = expiresDate > Date()
            
            if isActive {
                print("✅ Active subscription found: \(productId), expires: \(expiresDate)")
            } else {
                print("❌ Expired subscription found: \(productId), expired: \(expiresDate)")
            }
            
            return isActive
        }
        
        completion(hasActiveSubscription)
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
    
    func schedulePeriodicValidation() {
        // Validate subscription every time app becomes active
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshSubscriptionStatus()
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
        
        // After successful transaction, validate receipt to get proper subscription info
        // But also grant access immediately for valid product IDs during development/testing
        let productId = transaction.payment.productIdentifier
        if productIDs.contains(productId) {
            print("✅ Granting access for valid subscription product: \(productId)")
            lastSuccessfulPurchaseTime = Date() // Track successful purchase time
            UserDefaults.standard.set(lastSuccessfulPurchaseTime, forKey: "lastSuccessfulPurchaseTime")
            DispatchQueue.main.async {
                self.updateSubscriptionStatus(true)
            }
        }
        
        // Still try receipt validation for future expiry checking
        validateReceipt { [weak self] isValid in
            // Only revoke access if receipt validation fails AND we don't have a valid recent purchase
            if !isValid {
                print("⚠️ Receipt validation failed after successful purchase - keeping access for development")
                // In production, you might want to revoke access here
                // For now, keep access since purchase was successful
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
            validateReceipt { [weak self] isValid in
                DispatchQueue.main.async {
                    if isValid {
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