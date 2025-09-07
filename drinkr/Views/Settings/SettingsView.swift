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
    
    // Debug time manipulation
    #if DEBUG
    @StateObject private var debugTimeManager = DebugTimeManager.shared
    @State private var showingDebugDatePicker = false
    @State private var debugDate = Date()
    #endif
    
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
                        
                        // Subscription Section
                        subscriptionSection
                            .padding(.horizontal)
                        
                        // App Info Section
                        appInfoSection
                            .padding(.horizontal)
                        
                        // Legal Section
                        legalSection
                            .padding(.horizontal)
                        
                        // About Section
                        aboutSection
                            .padding(.horizontal)
                        
                        #if DEBUG
                        // Debug section
                        debugSection
                            .padding(.horizontal)
                        #endif
                        
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
            Text("Your name has been updated successfully")
        }
        .sheet(isPresented: $showingTerms) {
            SafariView(url: URL(string: "https://www.freeprivacypolicy.com/live/c8a0d137-7a09-4a53-a7de-b43c13619987")!)
        }
        .sheet(isPresented: $showingPrivacy) {
            SafariView(url: URL(string: "https://www.freeprivacypolicy.com/live/b6edc08d-395d-47ae-b9d2-699ead421394")!)
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
    
    #if DEBUG
    private func printDebugInfo() {
        print(String(repeating: "=", count: 50))
        print("🔍 DEBUG INFO - CURRENT STATE")
        print(String(repeating: "=", count: 50))
        
        let realSystemTime = Date()
        let debugTime = debugTimeManager.getCurrentTime()
        let debugOffset = debugTimeManager.debugTimeOffset
        let isDebugMode = debugTimeManager.isDebugMode
        
        print("📅 Real System Time: \(realSystemTime)")
        print("📅 Debug Time: \(debugTime)")
        print("⏰ Debug Offset: \(debugOffset) seconds")
        print("🔧 Debug Mode Active: \(isDebugMode)")
        print("")
        
        let timeComponents = dataService.getTimeComponents()
        print("📊 Current Days: \(timeComponents.days)")
        print("📊 Current Hours: \(timeComponents.hours)")
        print("📊 Current Minutes: \(timeComponents.minutes)")
        print("")
        
        let debugKey = isDebugMode ? "debugLastCelebratedMilestone" : "lastCelebratedMilestone"
        let lastCelebrated = UserDefaults.standard.integer(forKey: debugKey)
        print("🏆 Last Celebrated Milestone: \(lastCelebrated) (key: \(debugKey))")
        print("✅ Ready to celebrate? \(timeComponents.days > lastCelebrated)")
        print("")
        
        let milestones = [1, 7, 14, 30, 60, 90, 180, 365]
        let currentMilestone = milestones.first { $0 <= timeComponents.days && $0 > lastCelebrated }
        print("🎯 Next milestone that should trigger: \(currentMilestone ?? 0)")
        print(String(repeating: "=", count: 50))
    }
    
    private func forceTriggerMilestone() {
        print("🚨 FORCE triggering 30-day milestone celebration")
        
        // Send notification to force trigger milestone celebration
        NotificationCenter.default.post(
            name: NSNotification.Name("ForceMilestone"), 
            object: nil,
            userInfo: ["days": 30]
        )
    }
    
    private func triggerTestMilestone() {
        // Get current simulated days
        let currentDays = dataService.getTimeComponents().days
        print("🧪 Testing milestone for \(currentDays) days")
        
        // Send notification to trigger milestone celebration
        NotificationCenter.default.post(
            name: NSNotification.Name("TestMilestone"), 
            object: nil,
            userInfo: ["days": currentDays]
        )
    }
    
    private func clearAllMilestones() {
        UserDefaults.standard.removeObject(forKey: "debugLastCelebratedMilestone")
        UserDefaults.standard.removeObject(forKey: "lastCelebratedMilestone")
        print("🗑️ Cleared all milestone history - ready for fresh testing")
        
        // Show confirmation
        let alert = UIAlertController(title: "Milestone History Cleared", 
                                    message: "All milestone celebrations have been reset. You can now test milestones again.", 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
    #endif
    
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
    
    #if DEBUG
    var debugSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("DEBUG CONTROLS")
                .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                .foregroundColor(ColorTheme.dangerRed)
            
            VStack(spacing: 8) {
                // Current debug time display
                VStack(spacing: 0) {
                    HStack {
                        Text("Debug Mode")
                            .font(.system(size: isCompact ? 14 : 16))
                            .foregroundColor(ColorTheme.textSecondary)
                        
                        Spacer()
                        
                        Text(debugTimeManager.isDebugMode ? "Simulated" : "Real Time")
                            .font(.system(size: isCompact ? 14 : 16))
                            .foregroundColor(debugTimeManager.isDebugMode ? ColorTheme.dangerRed : ColorTheme.successGreen)
                    }
                    .padding(isCompact ? 15 : 18)
                    
                    if debugTimeManager.isDebugMode {
                        Divider()
                            .background(ColorTheme.cardBorder)
                        
                        HStack {
                            Text("Simulated Date")
                                .font(.system(size: isCompact ? 12 : 14))
                                .foregroundColor(ColorTheme.textSecondary)
                            
                            Spacer()
                            
                            Text(debugTimeManager.getCurrentTime(), style: .date)
                                .font(.system(size: isCompact ? 12 : 14))
                                .foregroundColor(ColorTheme.textPrimary)
                        }
                        .padding(.horizontal, isCompact ? 15 : 18)
                        
                        Divider()
                            .background(ColorTheme.cardBorder)
                        
                        HStack {
                            Text("Current Days")
                                .font(.system(size: isCompact ? 12 : 14))
                                .foregroundColor(ColorTheme.textSecondary)
                            
                            Spacer()
                            
                            let currentDays = dataService.getTimeComponents().days
                            let lastCelebrated = UserDefaults.standard.integer(forKey: debugTimeManager.isDebugMode ? "debugLastCelebratedMilestone" : "lastCelebratedMilestone")
                            
                            Text("\(currentDays) (last: \(lastCelebrated))")
                                .font(.system(size: isCompact ? 12 : 14))
                                .foregroundColor(currentDays > lastCelebrated ? ColorTheme.successGreen : ColorTheme.textPrimary)
                        }
                        .padding(.horizontal, isCompact ? 15 : 18)
                        .padding(.bottom, isCompact ? 15 : 18)
                    }
                }
                .background(Color.white.opacity(0.04))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ColorTheme.cardBorder, lineWidth: 1)
                )
                
                // Debug controls
                VStack(spacing: 8) {
                    // Set custom date button
                    Button(action: {
                        debugDate = debugTimeManager.getCurrentTime()
                        showingDebugDatePicker = true
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(ColorTheme.accentCyan)
                            Text("Set Custom Date/Time")
                                .font(.system(size: isCompact ? 14 : 16))
                                .foregroundColor(ColorTheme.accentCyan)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                        .padding(isCompact ? 15 : 18)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ColorTheme.cardBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Quick time jump buttons
                    HStack(spacing: 8) {
                        debugQuickButton("+1 Hour", hours: 1)
                        debugQuickButton("+1 Day", days: 1)
                        debugQuickButton("+1 Week", days: 7)
                    }
                    
                    HStack(spacing: 8) {
                        debugQuickButton("+30 Days", days: 30)
                        debugQuickButton("+1 Year", days: 365)
                        Spacer()
                    }
                    
                    // Show debug info button
                    Button(action: {
                        printDebugInfo()
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(ColorTheme.accentPurple)
                            Text("Show Debug Info in Console")
                                .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                                .foregroundColor(ColorTheme.accentPurple)
                            Spacer()
                        }
                        .padding(isCompact ? 12 : 15)
                        .background(ColorTheme.accentPurple.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(ColorTheme.accentPurple.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Force milestone button (bypasses all checks)
                    Button(action: {
                        forceTriggerMilestone()
                    }) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(ColorTheme.dangerRed)
                            Text("FORCE Milestone (30 days)")
                                .font(.system(size: isCompact ? 14 : 16, weight: .bold))
                                .foregroundColor(ColorTheme.dangerRed)
                            Spacer()
                        }
                        .padding(isCompact ? 12 : 15)
                        .background(ColorTheme.dangerRed.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(ColorTheme.dangerRed.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Test milestone button
                    Button(action: {
                        triggerTestMilestone()
                    }) {
                        HStack {
                            Image(systemName: "party.popper")
                                .foregroundColor(ColorTheme.accentCyan)
                            Text("Test Milestone Celebration")
                                .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                                .foregroundColor(ColorTheme.accentCyan)
                            Spacer()
                        }
                        .padding(isCompact ? 12 : 15)
                        .background(ColorTheme.accentCyan.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Clear milestones button
                    Button(action: {
                        clearAllMilestones()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(ColorTheme.warningOrange)
                            Text("Clear Milestone History")
                                .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                                .foregroundColor(ColorTheme.warningOrange)
                            Spacer()
                        }
                        .padding(isCompact ? 12 : 15)
                        .background(ColorTheme.warningOrange.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(ColorTheme.warningOrange.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Reset button
                    Button(action: {
                        debugTimeManager.resetToRealTime()
                        debugDate = Date()
                    }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(ColorTheme.dangerRed)
                            Text("Reset to Real Time")
                                .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                                .foregroundColor(ColorTheme.dangerRed)
                            Spacer()
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
        }
        .sheet(isPresented: $showingDebugDatePicker) {
            NavigationStack {
                VStack {
                    DatePicker(
                        "Debug Date & Time",
                        selection: $debugDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    
                    Spacer()
                }
                .navigationTitle("Set Debug Time")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingDebugDatePicker = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Set") {
                            debugTimeManager.setDebugTime(to: debugDate)
                            showingDebugDatePicker = false
                        }
                    }
                }
            }
        }
    }
    
    private func debugQuickButton(_ title: String, days: Int = 0, hours: Int = 0) -> some View {
        Button(action: {
            debugTimeManager.addTime(days: days, hours: hours)
            debugDate = debugTimeManager.getCurrentTime()
        }) {
            Text(title)
                .font(.system(size: isCompact ? 12 : 14, weight: .medium))
                .foregroundColor(ColorTheme.accentPurple)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(ColorTheme.accentPurple.opacity(0.1))
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    #endif
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