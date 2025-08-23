import SwiftUI

struct SettingsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var dataService: DataService
    @State private var userName: String = ""
    @State private var showingNameEdit = false
    @State private var tempName: String = ""
    @State private var showingSaveConfirmation = false
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                OptimizedBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: isCompact ? 20 : 25) {
                        // Profile Section
                        profileSection
                            .padding(.horizontal)
                            .padding(.top)
                        
                        // App Info Section
                        appInfoSection
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
            .background(ColorTheme.cardBackground)
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
            .background(ColorTheme.cardBackground)
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
            
            VStack(spacing: 0) {
                // Terms of Use
                Button(action: {
                    // Open terms of use
                    if let url = URL(string: "https://www.example.com/terms") {
                        UIApplication.shared.open(url)
                    }
                }) {
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
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .background(ColorTheme.cardBorder)
                
                // Privacy Policy
                Button(action: {
                    // Open privacy policy
                    if let url = URL(string: "https://www.example.com/privacy") {
                        UIApplication.shared.open(url)
                    }
                }) {
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
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(ColorTheme.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorTheme.cardBorder, lineWidth: 1)
            )
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
        .background(ColorTheme.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataService())
}