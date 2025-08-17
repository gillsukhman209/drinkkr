import SwiftUI

struct DashboardView: View {
    @State private var sobrietyDate = Date().addingTimeInterval(-86400 * 3)
    @State private var animationAmount = 1.0
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var timeComponents: (days: Int, hours: Int, minutes: Int) {
        let interval = Date().timeIntervalSince(sobrietyDate)
        let days = Int(interval) / 86400
        let hours = Int(interval) % 86400 / 3600
        let minutes = Int(interval) % 3600 / 60
        return (days, hours, minutes)
    }
    
    var isCompact: Bool {
        horizontalSizeClass == .compact || verticalSizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: isCompact ? 20 : 30) {
                        weekProgressIndicator
                            .padding(.top, isCompact ? 10 : 20)
                        
                        sobrietyTimerView
                            .padding(.horizontal)
                        
                        crystalAnimation
                            .frame(height: isCompact ? 200 : 250)
                            .padding(.vertical)
                        
                        actionButtons
                            .padding(.horizontal)
                            .padding(.bottom, isCompact ? 20 : 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var weekProgressIndicator: some View {
        HStack(spacing: isCompact ? 8 : 12) {
            ForEach(0..<7) { day in
                Circle()
                    .fill(day < 3 ? ColorTheme.accentCyan : Color.gray.opacity(0.3))
                    .frame(width: isCompact ? 35 : 40, height: isCompact ? 35 : 40)
                    .overlay(
                        Text(dayLabel(for: day))
                            .font(.system(size: isCompact ? 10 : 12, weight: .bold))
                            .foregroundColor(day < 3 ? .black : .gray)
                    )
                    .glowEffect(color: day < 3 ? ColorTheme.accentCyan : .clear, radius: 5)
            }
        }
        .padding(.horizontal)
    }
    
    func dayLabel(for index: Int) -> String {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        return days[index]
    }
    
    var sobrietyTimerView: some View {
        VStack(spacing: 10) {
            Text("You've been alcohol-free for")
                .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                .foregroundColor(ColorTheme.textSecondary)
            
            HStack(spacing: isCompact ? 15 : 20) {
                timeComponent(value: timeComponents.days, unit: "days")
                timeComponent(value: timeComponents.hours, unit: "hours")
                timeComponent(value: timeComponents.minutes, unit: "mins")
            }
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    func timeComponent(value: Int, unit: String) -> some View {
        VStack(spacing: 5) {
            Text("\(value)")
                .font(.system(size: isCompact ? 28 : 36, weight: .bold, design: .monospaced))
                .foregroundColor(ColorTheme.accentCyan)
                .glowEffect(radius: 5)
            
            Text(unit)
                .font(.system(size: isCompact ? 12 : 14, weight: .medium))
                .foregroundColor(ColorTheme.textSecondary)
        }
    }
    
    var crystalAnimation: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<3) { index in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    ColorTheme.accentCyan.opacity(0.3),
                                    ColorTheme.accentPurple.opacity(0.3),
                                    ColorTheme.accentPink.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                        .rotationEffect(.degrees(Double(index) * 60))
                        .scaleEffect(animationAmount)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: animationAmount
                        )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                animationAmount = 1.2
            }
        }
    }
    
    var actionButtons: some View {
        let columns = isCompact ? 
            [GridItem(.flexible()), GridItem(.flexible())] :
            [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        
        return LazyVGrid(columns: columns, spacing: isCompact ? 15 : 20) {
            actionButton(title: "Pledge", icon: "hand.raised.fill", color: ColorTheme.accentCyan)
            actionButton(title: "Meditate", icon: "leaf.fill", color: ColorTheme.accentPurple)
            actionButton(title: "Reset", icon: "arrow.clockwise", color: ColorTheme.warningOrange)
            actionButton(title: "Panic", icon: "exclamationmark.triangle.fill", color: ColorTheme.dangerRed)
        }
    }
    
    func actionButton(title: String, icon: String, color: Color) -> some View {
        Button(action: {
            print("\(title) button tapped")
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: isCompact ? 24 : 30))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                    .foregroundColor(ColorTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: isCompact ? 80 : 100)
            .futuristicCard()
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            }
        }
    }
}

#Preview {
    DashboardView()
}