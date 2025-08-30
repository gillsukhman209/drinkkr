import SwiftUI

struct OnboardingCommitmentView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isVisible = false
    @State private var selectedQuitOption = 0 // 0: Today, 1: Tomorrow, 2: Custom
    @State private var customDate = Date()
    @State private var checkInTime = Date()
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    private var quitDate: Date {
        switch selectedQuitOption {
        case 0: return Date() // Today means right now, not start of day
        case 1: return Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date())
        case 2: return Calendar.current.startOfDay(for: customDate)
        default: return Date()
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: isCompact ? 25 : 35) {
                // Header
                VStack(spacing: 15) {
                    Text("I'm ready to take control\nof my life")
                        .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .offset(y: isVisible ? 0 : -20)
                    
                    Text("Making this commitment is a powerful first step")
                        .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        .foregroundColor(ColorTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .offset(y: isVisible ? 0 : -15)
                }
                .padding(.top, isCompact ? 20 : 30)
                
                // Quit date selection
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("When do you want to start?")
                            .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                        
                        VStack(spacing: 10) {
                            quitDateOption(title: "Today", subtitle: "Start your journey right now", index: 0)
                            quitDateOption(title: "Tomorrow", subtitle: "Give yourself one day to prepare", index: 1)
                            quitDateOption(title: "Choose a date", subtitle: "Pick the perfect day for you", index: 2)
                        }
                    }
                    
                    // Custom date picker
                    if selectedQuitOption == 2 {
                        customDatePicker
                            .opacity(isVisible ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedQuitOption)
                    }
                }
                .padding(.horizontal, 20)
                
                // Check-in time
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Daily check-in time")
                            .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                        
                        Text("We'll send you a gentle reminder to log your progress")
                            .font(.system(size: isCompact ? 14 : 16))
                            .foregroundColor(ColorTheme.textSecondary)
                            .padding(.horizontal, 5)
                        
                        checkInTimePicker
                    }
                }
                .padding(.horizontal, 20)
                
                // Commitment message
                commitmentMessage
                    .padding(.horizontal, 20)
                    .opacity(isVisible ? 1.0 : 0.0)
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                isVisible = true
            }
            
            // Set default check-in time to 7 PM
            let calendar = Calendar.current
            let components = DateComponents(hour: 19, minute: 0)
            checkInTime = calendar.date(from: components) ?? Date()
        }
        .onChange(of: quitDate) {
            updateViewModelData()
        }
        .onChange(of: checkInTime) {
            updateViewModelData()
        }
        .onDisappear {
            isVisible = false
        }
    }
    
    private func quitDateOption(title: String, subtitle: String, index: Int) -> some View {
        let isSelected = selectedQuitOption == index
        
        return Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                selectedQuitOption = index
            }
        }) {
            HStack(spacing: 15) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? ColorTheme.accentCyan : Color.white.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(ColorTheme.accentCyan)
                            .frame(width: 12, height: 12)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: isCompact ? 14 : 15))
                        .foregroundColor(ColorTheme.textSecondary)
                }
                
                Spacer()
                
                // Date display
                if index == 0 {
                    Text("Right now")
                        .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        .foregroundColor(ColorTheme.accentCyan)
                } else if index == 1 {
                    Text(formatDate(quitDate))
                        .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        .foregroundColor(ColorTheme.accentCyan)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        ColorTheme.accentCyan.opacity(0.15) :
                        Color.white.opacity(0.05)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? ColorTheme.accentCyan.opacity(0.5) : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: isVisible)
    }
    
    private var customDatePicker: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Select your quit date")
                    .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(formatDate(customDate))
                    .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                    .foregroundColor(ColorTheme.accentCyan)
            }
            
            DatePicker(
                "Quit Date",
                selection: $customDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
            .colorScheme(.dark)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var checkInTimePicker: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "bell.fill")
                    .font(.system(size: 16))
                    .foregroundColor(ColorTheme.accentPurple)
                
                Text("I'll check in at")
                    .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(formatTime(checkInTime))
                    .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                    .foregroundColor(ColorTheme.accentPurple)
            }
            
            DatePicker(
                "Check-in Time",
                selection: $checkInTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
            .colorScheme(.dark)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ColorTheme.accentPurple.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ColorTheme.accentPurple.opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: isVisible)
    }
    
    private var commitmentMessage: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundColor(ColorTheme.accentPink)
                
                Text("Your commitment")
                    .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                    .foregroundColor(ColorTheme.accentPink)
            }
            
            VStack(spacing: 12) {
                commitmentItem(icon: "calendar", text: selectedQuitOption == 0 ? "I'm starting my alcohol-free journey right now" : "I will start my alcohol-free journey on \(formatDate(quitDate))")
                commitmentItem(icon: "clock", text: "I will check in daily at \(formatTime(checkInTime))")
                commitmentItem(icon: "star", text: "I will be patient and kind with myself throughout this process")
                commitmentItem(icon: "heart", text: "I will reach out for support when I need it")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [ColorTheme.accentPink.opacity(0.1), ColorTheme.accentPurple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ColorTheme.accentPink.opacity(0.3), lineWidth: 1)
                )
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: isVisible)
    }
    
    private func commitmentItem(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(ColorTheme.accentCyan)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: isCompact ? 14 : 15))
                .foregroundColor(ColorTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
    
    private func updateViewModelData() {
        viewModel.userProfile.quitDate = quitDate
        viewModel.userProfile.checkInTime = checkInTime
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Permission View

struct OnboardingPermissionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isVisible = false
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        VStack(spacing: isCompact ? 30 : 40) {
            Spacer()
            
            // Shield icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [ColorTheme.accentCyan.opacity(0.3), ColorTheme.accentPurple.opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: isCompact ? 120 : 150, height: isCompact ? 120 : 150)
                    .scaleEffect(isVisible ? 1.0 : 0.8)
                
                Image(systemName: "shield.checkered")
                    .font(.system(size: isCompact ? 60 : 80, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ColorTheme.accentCyan, ColorTheme.accentPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(isVisible ? 1.0 : 0.5)
            }
            
            // Content
            VStack(spacing: 20) {
                Text("Stay on track with\ngentle reminders")
                    .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .offset(y: isVisible ? 0 : 20)
                
                Text("We'll send you supportive notifications to help you maintain your momentum and celebrate your progress.")
                    .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .offset(y: isVisible ? 0 : 20)
            }
            
            // Benefits
            VStack(spacing: 16) {
                permissionBenefit(
                    icon: "bell.badge",
                    title: "Daily check-ins",
                    subtitle: "Gentle reminders at your chosen time"
                )
                
                permissionBenefit(
                    icon: "heart.text.square",
                    title: "Milestone celebrations",
                    subtitle: "Celebrate your achievements with you"
                )
                
                permissionBenefit(
                    icon: "lightbulb",
                    title: "Helpful tips",
                    subtitle: "Timely advice when you need it most"
                )
            }
            .padding(.horizontal, 20)
            .opacity(isVisible ? 1.0 : 0.0)
            .offset(y: isVisible ? 0 : 30)
            
            Spacer()
            
            // Privacy note
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Text("Your privacy matters")
                        .font(.system(size: isCompact ? 12 : 14, weight: .medium))
                        .foregroundColor(ColorTheme.textSecondary)
                }
                
                Text("You can always change notification settings in the app")
                    .font(.system(size: isCompact ? 11 : 13))
                    .foregroundColor(ColorTheme.textSecondary.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            .opacity(isVisible ? 1.0 : 0.0)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
    
    private func permissionBenefit(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(ColorTheme.accentCyan)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ColorTheme.accentCyan.opacity(0.2), lineWidth: 1)
                )
        )
    }
}


#Preview {
    ZStack {
        OptimizedBackground()
            .ignoresSafeArea()
        
        OnboardingCommitmentView(viewModel: OnboardingViewModel())
    }
}