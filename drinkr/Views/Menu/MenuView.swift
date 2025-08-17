import SwiftUI

struct MenuView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = true
    @State private var showingResetAlert = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var dataService: DataService
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: isCompact ? 20 : 25) {
                        accountSection
                            .padding(.horizontal)
                            .padding(.top)
                        
                        settingsSection
                            .padding(.horizontal)
                        
                        supportSection
                            .padding(.horizontal)
                        
                        dangerZone
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset Progress", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetProgress()
                }
            } message: {
                Text("Are you sure you want to reset all your progress? This action cannot be undone.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var accountSection: some View {
        VStack(spacing: 15) {
            sectionHeader("Account")
            
            menuItem(icon: "person.circle.fill", title: "Profile", subtitle: "Edit your information") {
                print("Profile tapped")
            }
            
            menuItem(icon: "trophy.fill", title: "Achievements", subtitle: "View your badges") {
                print("Achievements tapped")
            }
        }
    }
    
    var settingsSection: some View {
        VStack(spacing: 15) {
            sectionHeader("Settings")
            
            toggleItem(
                icon: "bell.fill",
                title: "Notifications",
                subtitle: "Daily reminders",
                isOn: $notificationsEnabled
            )
            
            toggleItem(
                icon: "moon.fill",
                title: "Dark Mode",
                subtitle: "Always enabled",
                isOn: $darkModeEnabled
            )
            
            menuItem(icon: "clock.fill", title: "Reminder Time", subtitle: "9:00 AM") {
                print("Reminder time tapped")
            }
        }
    }
    
    var supportSection: some View {
        VStack(spacing: 15) {
            sectionHeader("Support")
            
            menuItem(icon: "questionmark.circle.fill", title: "Help Center", subtitle: "FAQs and guides") {
                print("Help center tapped")
            }
            
            menuItem(icon: "envelope.fill", title: "Contact Us", subtitle: "Get in touch") {
                print("Contact tapped")
            }
            
            menuItem(icon: "star.fill", title: "Rate App", subtitle: "Share your feedback") {
                print("Rate app tapped")
            }
            
            menuItem(icon: "square.and.arrow.up.fill", title: "Share App", subtitle: "Help others") {
                print("Share app tapped")
            }
        }
    }
    
    var dangerZone: some View {
        VStack(spacing: 15) {
            sectionHeader("Danger Zone")
                .foregroundColor(ColorTheme.dangerRed)
            
            Button(action: {
                showingResetAlert = true
            }) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: isCompact ? 20 : 24))
                        .foregroundColor(ColorTheme.dangerRed)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Reset All Progress")
                            .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                            .foregroundColor(ColorTheme.dangerRed)
                        
                        Text("This cannot be undone")
                            .font(.system(size: isCompact ? 12 : 14))
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding(isCompact ? 15 : 20)
                .background(ColorTheme.dangerRed.opacity(0.1))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(ColorTheme.dangerRed.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: isCompact ? 18 : 20, weight: .bold))
            .foregroundColor(ColorTheme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func menuItem(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: isCompact ? 20 : 24))
                    .foregroundColor(ColorTheme.accentCyan)
                    .frame(width: isCompact ? 30 : 35)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: isCompact ? 12 : 14))
                        .foregroundColor(ColorTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            .padding(isCompact ? 15 : 20)
            .futuristicCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func toggleItem(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 20 : 24))
                .foregroundColor(ColorTheme.accentCyan)
                .frame(width: isCompact ? 30 : 35)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: isCompact ? 12 : 14))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: ColorTheme.accentCyan))
                .labelsHidden()
        }
        .padding(isCompact ? 15 : 20)
        .futuristicCard()
    }
    
    func resetProgress() {
        dataService.resetProgress()
    }
}

#Preview {
    MenuView()
        .environmentObject(DataService())
}