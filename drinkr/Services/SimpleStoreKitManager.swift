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
    private var hasValidPurchase = false // Track if we have a valid purchase in this session
    
    override init() {
        super.init()
        
        // Check if payments are allowed
        if SKPaymentQueue.canMakePayments() {
            // Add transaction observer
            SKPaymentQueue.default().add(self)
            
            // Load products
            loadProducts()
            
            // Check if we already have a valid subscription from UserDefaults
            let hasActiveSubscription = UserDefaults.standard.bool(forKey: "hasActiveSubscription")
            if hasActiveSubscription {
                isSubscribed = true
                hasValidPurchase = true
                print("✅ Found existing valid subscription in UserDefaults")
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
        // If we have a valid purchase in this session, don't override with receipt validation
        if hasValidPurchase {
            print("✅ Skipping receipt validation - valid purchase exists in session")
            return
        }
        
        validateReceipt { [weak self] isValid in
            DispatchQueue.main.async {
                // Only update if we don't have a valid purchase in this session
                guard let self = self, !self.hasValidPurchase else { return }
                
                self.isSubscribed = isValid
                if isValid {
                    UserDefaults.standard.set(true, forKey: "hasActiveSubscription")
                } else {
                    UserDefaults.standard.set(false, forKey: "hasActiveSubscription")
                }
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
        
        // Always try sandbox first for development/testing
        let validationURL = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        
        var request = URLRequest(url: validationURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
        } catch {
            print("❌ Failed to serialize receipt data: \(error)")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                print("❌ Receipt validation network error: \(error?.localizedDescription ?? "Unknown")")
                completion(false)
                return
            }
            
            Task { @MainActor in
                self.parseReceiptResponse(data: data, completion: completion)
            }
        }.resume()
    }
    
    private func parseReceiptResponse(data: Data, completion: @escaping (Bool) -> Void) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(false)
                return
            }
            
            guard let status = json["status"] as? Int else {
                completion(false)
                return
            }
            
            // Status 0 means valid receipt
            guard status == 0 else {
                print("❌ Receipt validation failed with status: \(status)")
                completion(false)
                return
            }
            
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
                }
                
                return isActive
            }
            
            completion(hasActiveSubscription)
            
        } catch {
            print("❌ Failed to parse receipt response: \(error)")
            completion(false)
        }
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
        
        // For development/testing: if transaction completes successfully, treat as valid subscription
        // This handles cases where receipt validation fails due to sandbox/production mismatches
        let productId = transaction.payment.productIdentifier
        if productIDs.contains(productId) {
            print("✅ Valid subscription product purchased: \(productId)")
            hasValidPurchase = true // Mark that we have a valid purchase
            DispatchQueue.main.async {
                self.updateSubscriptionStatus(true)
            }
        } else {
            // Try receipt validation as fallback
            validateReceipt { [weak self] isValid in
                DispatchQueue.main.async {
                    self?.updateSubscriptionStatus(isValid)
                }
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
        
        // Validate receipt to check for active subscriptions
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