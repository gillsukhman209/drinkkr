import SwiftUI
import SafariServices

struct SettingsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var dataService: DataService
    @StateObject private var superwallManager = SuperwallManager.shared
    @State private var userName: String = ""
    @State private var showingNameEdit = false
    @State private var tempName: String = ""
    @State private var showingSaveConfirmation = false
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    @State private var isRestoringPurchases = false
    @State private var showingResetConfirmation = false
    @State private var notificationsEnabled = true
    @State private var notificationTime = Date()
    
    // Savings Settings
    @State private var costPerMeal: Double = 15.0
    @State private var showingCostEdit = false
    @State private var tempCost: String = ""
    

    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
                OptimizedBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: isCompact ? 20 : 25) {
                        // Profile Section
                        profileSection
                            .padding(.horizontal)
                            .padding(.top)
                        
                        // Savings Section
                        savingsSection
                            .padding(.horizontal)
                        
                        // Subscription Section
                        subscriptionSection
                            .padding(.horizontal)
                        
                        // App Info Section
                        appInfoSection
                            .padding(.horizontal)
                        
                        // Notifications Section
                        notificationsSection
                            .padding(.horizontal)
                        
                        // Data Management Section
                        dataManagementSection
                            .padding(.horizontal)
                        
                        // Legal Section
                        legalSection
                            .padding(.horizontal)
                        
                        // About Section
                        aboutSection
                            .padding(.horizontal)
                        

                        
                        Spacer()
                            .frame(height: 30)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        .onAppear {
            userName = dataService.currentUser?.name ?? ""
            tempName = userName
            
            if let cost = dataService.cleanEatingData?.costPerMeal {
                costPerMeal = cost
                tempCost = String(format: "%.2f", cost)
            }
        }
        .alert("Update Name", isPresented: $showingNameEdit) {
            TextField("Enter your name", text: $tempName)
                .textInputAutocapitalization(.words)
            Button("Cancel", role: .cancel) {
                tempName = userName
            }
            Button("Save") {
                if !tempName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    userName = tempName
                    dataService.updateUserName(userName)
                    showingSaveConfirmation = true
                }
            }
        } message: {
            Text("This name will be displayed throughout the app")
        }
        .alert("Success", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your changes have been saved successfully")
        }
        .alert("Update Meal Cost", isPresented: $showingCostEdit) {
            TextField("Cost per meal ($)", text: $tempCost)
                .keyboardType(.decimalPad)
            Button("Cancel", role: .cancel) {
                if let cost = dataService.cleanEatingData?.costPerMeal {
                    tempCost = String(format: "%.2f", cost)
                }
            }
            Button("Save") {
                if let cost = Double(tempCost), cost > 0 {
                    costPerMeal = cost
                    dataService.updateCostPerMeal(cost)
                    showingSaveConfirmation = true
                }
            }
        } message: {
            Text("Enter the average cost of a fast food meal to calculate your savings.")
        }
        .sheet(isPresented: $showingTerms) {
            SafariView(url: URL(string: "https://www.freeprivacypolicy.com/live/c8a0d137-7a09-4a53-a7de-b43c13619987")!)
        }
        .sheet(isPresented: $showingPrivacy) {
            SafariView(url: URL(string: "https://www.freeprivacypolicy.com/live/b6edc08d-395d-47ae-b9d2-699ead421394")!)
        }
        .alert("Reset Progress?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                dataService.resetProgress()
            }
        } message: {
            Text("This will clear all your progress, streaks, and stats. This action cannot be undone.")
        }
    }
    
    private func restorePurchases() {
        isRestoringPurchases = true
        
        superwallManager.restorePurchases()
        
        // Show feedback after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isRestoringPurchases = false
            
            if superwallManager.isSubscribed {
                // Show success message
                print("✅ Purchases restored successfully!")
            } else {
                // Show message that no purchases were found
                print("ℹ️ No active subscriptions found")
            }
        }
    }
    

    
    var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("SUBSCRIPTION")
                .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                .foregroundColor(ColorTheme.textSecondary)
            
            VStack(spacing: 0) {
                // Subscription Status Row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Status")
                            .font(.system(size: isCompact ? 14 : 16))
                            .foregroundColor(ColorTheme.textSecondary)
                        Text(superwallManager.isSubscribed ? "Premium" : "Free")
                            .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                            .foregroundColor(superwallManager.isSubscribed ? ColorTheme.successGreen : ColorTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    if superwallManager.isSubscribed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: isCompact ? 20 : 24))
                            .foregroundColor(ColorTheme.successGreen)
                    }
                }
                .padding(isCompact ? 15 : 18)
                
                Divider()
                    .background(ColorTheme.cardBorder)
                
                // Restore Purchases Row
                Button(action: {
                    restorePurchases()
                }) {
                    HStack {
                        Text("Restore Purchases")
                            .font(.system(size: isCompact ? 14 : 16))
                            .foregroundColor(ColorTheme.accentCyan)
                        
                        Spacer()
                        
                        if isRestoringPurchases {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: ColorTheme.accentCyan))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: isCompact ? 16 : 18))
                                .foregroundColor(ColorTheme.accentCyan)
                        }
                    }
                    .padding(isCompact ? 15 : 18)
                }
                .disabled(isRestoringPurchases)
                .buttonStyle(PlainButtonStyle())
            }
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorTheme.cardBorder, lineWidth: 1)
            )
        }
    }
    
    var profileSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("PROFILE")
                .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                .foregroundColor(ColorTheme.textSecondary)
            
            VStack(spacing: 0) {
                // Name Edit Row
                Button(action: {
                    tempName = userName
                    showingNameEdit = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Name")
                                .font(.system(size: isCompact ? 14 : 16))
                                .foregroundColor(ColorTheme.textSecondary)
                            Text(userName.isEmpty ? "Set your name" : userName)
                                .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                                .foregroundColor(ColorTheme.textPrimary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "pencil")
                            .font(.system(size: isCompact ? 16 : 18))
                            .foregroundColor(ColorTheme.accentCyan)
                    }
                    .padding(isCompact ? 15 : 18)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorTheme.cardBorder, lineWidth: 1)
            )
        }
    }
    
    var savingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("SAVINGS SETTINGS")
                .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                .foregroundColor(ColorTheme.textSecondary)
            
            VStack(spacing: 0) {
                // Cost Per Meal Row
                Button(action: {
                    if let cost = dataService.cleanEatingData?.costPerMeal {
                        tempCost = String(format: "%.2f", cost)
                    }
                    showingCostEdit = true
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Average Meal Cost")
                                .font(.system(size: isCompact ? 14 : 16))
                                .foregroundColor(ColorTheme.textSecondary)
                            Text("$\(String(format: "%.2f", costPerMeal))")
                                .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                                .foregroundColor(ColorTheme.textPrimary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "pencil")
                            .font(.system(size: isCompact ? 16 : 18))
                            .foregroundColor(ColorTheme.accentCyan)
                    }
                    .padding(isCompact ? 15 : 18)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorTheme.cardBorder, lineWidth: 1)
            )
        }
    }
    
    var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("APP INFO")
                .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                .foregroundColor(ColorTheme.textSecondary)
            
            VStack(spacing: 0) {
                // Version Row
                HStack {
                    Text("Version")
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Spacer()
                    
                    Text("1.0.0")
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(ColorTheme.textPrimary)
                }
                .padding(isCompact ? 15 : 18)
                
                Divider()
                    .background(ColorTheme.cardBorder)
                
                // Build Row
                HStack {
                    Text("Build")
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Spacer()
                    
                    Text("2025.1")
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(ColorTheme.textPrimary)
                }
                .padding(isCompact ? 15 : 18)
            }
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorTheme.cardBorder, lineWidth: 1)
            )
        }
    }
    
    var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("NOTIFICATIONS")
                .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                .foregroundColor(ColorTheme.textSecondary)
            
            VStack(spacing: 0) {
                Toggle("Daily Check-in", isOn: $notificationsEnabled)
                    .padding(isCompact ? 15 : 18)
                    .onChange(of: notificationsEnabled) { _, newValue in
                        if newValue {
                            NotificationService.shared.scheduleDailyCheckIn(at: notificationTime)
                        } else {
                            NotificationService.shared.cancelAllNotifications()
                        }
                    }
                
                if notificationsEnabled {
                    Divider()
                        .background(ColorTheme.cardBorder)
                    
                    DatePicker("Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                        .padding(isCompact ? 15 : 18)
                        .onChange(of: notificationTime) { _, newTime in
                            NotificationService.shared.scheduleDailyCheckIn(at: newTime)
                        }
                }
            }
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorTheme.cardBorder, lineWidth: 1)
            )
        }
    }
    
    var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("DATA MANAGEMENT")
                .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                .foregroundColor(ColorTheme.textSecondary)
            
            Button(action: {
                showingResetConfirmation = true
            }) {
                HStack {
                    Text("Reset Progress")
                        .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        .foregroundColor(ColorTheme.dangerRed)
                    
                    Spacer()
                    
                    Image(systemName: "trash")
                        .font(.system(size: isCompact ? 16 : 18))
                        .foregroundColor(ColorTheme.dangerRed)
                }
                .padding(isCompact ? 15 : 18)
                .background(ColorTheme.dangerRed.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ColorTheme.dangerRed.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }

    }
    var legalSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("LEGAL")
                .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                .foregroundColor(ColorTheme.textSecondary)
            
            VStack(spacing: 8) {
                // Terms of Use Button
                Button {
                    print("Terms button tapped!") // Debug
                    showingTerms = true
                } label: {
                    HStack {
                        Text("Terms of Use")
                            .font(.system(size: isCompact ? 14 : 16))
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: isCompact ? 14 : 16))
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    .padding(isCompact ? 15 : 18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(ColorTheme.cardBorder, lineWidth: 1)
                    )
                }
                
                // Privacy Policy Button
                Button {
                    print("Privacy button tapped!") // Debug
                    showingPrivacy = true
                } label: {
                    HStack {
                        Text("Privacy Policy")
                            .font(.system(size: isCompact ? 14 : 16))
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: isCompact ? 14 : 16))
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    .padding(isCompact ? 15 : 18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(ColorTheme.cardBorder, lineWidth: 1)
                    )
                }
            }
        }
    }
    
    var aboutSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart.fill")
                .font(.system(size: isCompact ? 30 : 36))
                .foregroundColor(ColorTheme.accentCyan)
            
            Text("Made with care for your journey")
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("Every day sober is a victory")
                .font(.system(size: isCompact ? 12 : 14))
                .foregroundColor(ColorTheme.textSecondary.opacity(0.7))
                .italic()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isCompact ? 20 : 25)
        .background(Color.white.opacity(0.02))
        .cornerRadius(12)
    }
    

}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredBarTintColor = UIColor.systemBackground
        safariViewController.preferredControlTintColor = UIColor.systemBlue
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        // No update needed
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataService())
}