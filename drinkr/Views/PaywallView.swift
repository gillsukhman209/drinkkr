import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var storeManager = SimpleStoreKitManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SKProduct?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            // App-consistent background
            ColorTheme.backgroundGradient
                .ignoresSafeArea()
            
            // Starfield background for consistency
            StarfieldBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                // Header section
                VStack(spacing: 24) {
                    // Title
                    Text("TRACK YOUR PROGRESS")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    
                }
                
                // Phone mockup
                phoneMockupView
                    .padding(.vertical, 30)
                
                // Benefits list
                VStack(alignment: .leading, spacing: 20) {
                    benefitItem(text: "Access tools to calm down or refocus")
                    benefitItem(text: "Discover spaces and routines that support recovery.")
                    benefitItem(text: "Understand the root causes of your urges.")
                    benefitItem(text: "Identify what pulls you back and regain control.")
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                
                // Pricing cards
                VStack(spacing: 12) {
                    // Annual plan with SAVE badge
                    if let yearly = storeManager.yearlyProduct() {
                        quittrAnnualCard(product: yearly)
                    }
                    
                    // Weekly plan
                    if let weekly = storeManager.weeklyProduct() {
                        quittrWeeklyCard(product: weekly)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                
                // CTA Button
                ctaButton
                    .padding(.bottom, 16)
                
                // Footer with subscription terms
                VStack(spacing: 12) {
                    // Important subscription information
                    Text("Subscription Terms")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period.")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    HStack(spacing: 20) {
                        Button("Restore Purchases") {
                            storeManager.restorePurchases()
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ColorTheme.accentCyan)
                        
                        Text("•")
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Cancel anytime")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 40)
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            // Always default to annual plan for higher conversion
            selectedPlan = storeManager.yearlyProduct()
        }
        .onChange(of: storeManager.availableProducts) {
            // Always default to annual plan for higher conversion
            if selectedPlan == nil {
                selectedPlan = storeManager.yearlyProduct()
            }
        }
        .onChange(of: storeManager.isSubscribed) {
            if storeManager.isSubscribed {
                // Add a small delay to ensure subscription is fully processed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
        .alert("Subscription", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: storeManager.errorMessage) {
            if let error = storeManager.errorMessage {
                alertMessage = error
                showingAlert = true
            }
        }
    }
    
    private var phoneMockupView: some View {
        VStack {
            // Phone frame
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black)
                .frame(width: 160, height: 320)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(ColorTheme.backgroundGradient)
                        .padding(4)
                        .overlay(
                            VStack(spacing: 20) {
                                // Status bar
                                HStack {
                                    Text("9:41")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, 15)
                                .padding(.top, 10)
                                
                                // Analytics header
                                HStack {
                                    Text("Analytics")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button("Share") {}
                                        .font(.system(size: 14))
                                        .foregroundColor(ColorTheme.accentCyan)
                                }
                                .padding(.horizontal, 15)
                                
                                // Progress ring
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 6)
                                        .frame(width: 80, height: 80)
                                    
                                    Circle()
                                        .trim(from: 0, to: 0.9)
                                        .stroke(
                                            LinearGradient(
                                                colors: [ColorTheme.accentCyan, ColorTheme.successGreen],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                                        )
                                        .frame(width: 80, height: 80)
                                        .rotationEffect(.degrees(-90))
                                    
                                    VStack(spacing: 2) {
                                        Text("RECOVERY")
                                            .font(.system(size: 8, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        Text("90%")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text("80 D STREAK")
                                            .font(.system(size: 7, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                
                                // Progress chart
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Your progress")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    
                                    // Chart
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 40)
                                        .overlay(
                                            HStack {
                                                ForEach(0..<15, id: \.self) { _ in
                                                    Rectangle()
                                                        .fill(ColorTheme.accentCyan.opacity(Double.random(in: 0.3...1.0)))
                                                        .frame(width: 1.5, height: CGFloat.random(in: 8...30))
                                                    Spacer(minLength: 1)
                                                }
                                            }
                                            .padding(.horizontal, 10)
                                        )
                                    
                                    HStack {
                                        Text("First login date")
                                            .font(.system(size: 10))
                                            .foregroundColor(.white.opacity(0.5))
                                        Spacer()
                                        Text("Today")
                                            .font(.system(size: 10))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                                .padding(.horizontal, 15)
                                
                                Spacer()
                            }
                        )
                )
        }
    }
    
    private func benefitItem(text: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(ColorTheme.successGreen)
                .font(.system(size: 20))
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
    
    
    private func quittrAnnualCard(product: SKProduct) -> some View {
        VStack(spacing: 0) {
            // SAVE badge - smaller and subordinate
            HStack {
                Spacer()
                Text("SAVE 85% + 3-DAY FREE TRIAL")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(ColorTheme.accentPink.opacity(0.8))
                    )
                Spacer()
            }
            .padding(.bottom, -8)
            .zIndex(1)
            
            // Main card
            Button {
                selectedPlan = product
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Annual")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Make billed amount MOST prominent
                        Text(storeManager.formattedPrice(for: product))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Billed yearly")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.6))
                        
                        // Free trial notice - clear but subordinate
                        Text("3-day free trial, then \(storeManager.formattedPrice(for: product))/year")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(ColorTheme.accentCyan.opacity(0.8))
                            .padding(.top, 2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("equals")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white.opacity(0.5))
                        Text(weeklyEquivalent(for: product))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ColorTheme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    selectedPlan?.productIdentifier == product.productIdentifier ? 
                                    ColorTheme.accentCyan : Color.white.opacity(0.3),
                                    lineWidth: selectedPlan?.productIdentifier == product.productIdentifier ? 2 : 1
                                )
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func quittrWeeklyCard(product: SKProduct) -> some View {
        Button {
            selectedPlan = product
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Weekly")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    // Make billed amount MOST prominent
                    Text(storeManager.formattedPrice(for: product))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Billed weekly")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Text("/week")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ColorTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                selectedPlan?.productIdentifier == product.productIdentifier ? 
                                ColorTheme.accentCyan : Color.white.opacity(0.3),
                                lineWidth: selectedPlan?.productIdentifier == product.productIdentifier ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    
    private var ctaButton: some View {
        Button {
            if let selectedPlan = selectedPlan {
                storeManager.purchase(selectedPlan)
            }
        } label: {
            HStack {
                if storeManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                VStack(spacing: 2) {
                    Text(storeManager.isLoading ? "Starting..." : getButtonText())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if !storeManager.isLoading && selectedPlan?.productIdentifier == storeManager.yearlyProduct()?.productIdentifier {
                        Text("Start 3-day free trial")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 27)
                    .fill(
                        LinearGradient(
                            colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .glowEffect(color: ColorTheme.accentCyan, radius: 15)
            )
        }
        .disabled(storeManager.isLoading || selectedPlan == nil)
        .scaleEffect(storeManager.isLoading ? 0.95 : 1.0)
        .animation(.spring(response: 0.3), value: storeManager.isLoading)
        .padding(.horizontal, 30)
    }
    
    private var compactFooter: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                Text("🛡️ 30-day guarantee")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("❌ Cancel anytime")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Button("Restore Purchases") {
                storeManager.restorePurchases()
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(ColorTheme.accentCyan)
            .disabled(storeManager.isLoading)
        }
    }
    
    
    private func weeklyEquivalent(for product: SKProduct) -> String {
        let weeklyPrice = product.price.doubleValue / 52
        return String(format: "$%.2f/wk", weeklyPrice)
    }
    
    private func getButtonText() -> String {
        if selectedPlan?.productIdentifier == storeManager.yearlyProduct()?.productIdentifier {
            return "TRY FREE & SUBSCRIBE"
        } else {
            return "SUBSCRIBE NOW"
        }
    }
}

#Preview {
    PaywallView()
        .preferredColorScheme(.dark)
}