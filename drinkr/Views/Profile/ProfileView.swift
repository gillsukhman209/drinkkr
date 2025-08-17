import SwiftUI

struct ProfileView: View {
    @State private var selectedTimeFrame = "Today"
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var dataService: DataService
    
    let timeFrames = ["Today", "This Week", "This Month"]
    
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
                        profileHeader
                            .padding(.horizontal)
                            .padding(.top)
                        
                        streakCards
                            .padding(.horizontal)
                        
                        timeFramePicker
                            .padding(.horizontal)
                        
                        statsView
                            .padding(.horizontal)
                        
                        relapseCounter
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Your Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var profileHeader: some View {
        HStack(spacing: isCompact ? 15 : 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: isCompact ? 60 : 80))
                .foregroundColor(ColorTheme.accentCyan)
                .glowEffect(radius: 10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Welcome back")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(ColorTheme.textSecondary)
                
                Text(dataService.currentUser?.name ?? "Anonymous")
                    .font(.system(size: isCompact ? 22 : 26, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(dataService.sobrietyData?.currentStreak ?? 0) Day Streak")
                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    var streakCards: some View {
        HStack(spacing: isCompact ? 12 : 15) {
            streakCard(title: "Current", value: "\(dataService.sobrietyData?.currentStreak ?? 0)", unit: "days", color: ColorTheme.successGreen)
            streakCard(title: "Best", value: "\(dataService.sobrietyData?.longestStreak ?? 0)", unit: "days", color: ColorTheme.accentPurple)
        }
    }
    
    func streakCard(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: isCompact ? 12 : 14))
                .foregroundColor(ColorTheme.textSecondary)
            
            Text(value)
                .font(.system(size: isCompact ? 36 : 44, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .glowEffect(color: color, radius: 5)
            
            Text(unit)
                .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                .foregroundColor(ColorTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    var timeFramePicker: some View {
        HStack(spacing: 0) {
            ForEach(timeFrames, id: \.self) { timeFrame in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTimeFrame = timeFrame
                    }
                }) {
                    Text(timeFrame)
                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                        .foregroundColor(selectedTimeFrame == timeFrame ? .black : ColorTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, isCompact ? 12 : 15)
                        .background(
                            selectedTimeFrame == timeFrame ?
                            AnyView(ColorTheme.accentCyan) :
                            AnyView(Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(ColorTheme.cardBackground)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
        )
    }
    
    var statsView: some View {
        VStack(spacing: isCompact ? 15 : 20) {
            statRow(label: "Money Saved", value: "$\(Int(dataService.sobrietyData?.moneySaved ?? 0))", icon: "dollarsign.circle.fill", color: ColorTheme.successGreen)
            statRow(label: "Drinks Avoided", value: "\(dataService.sobrietyData?.drinksAvoided ?? 0)", icon: "wineglass", color: ColorTheme.accentPurple)
            statRow(label: "Calories Saved", value: "\(dataService.sobrietyData?.caloriesSaved ?? 0)", icon: "flame.fill", color: .orange)
            statRow(label: "Time Reclaimed", value: "\(Int(dataService.sobrietyData?.timeReclaimed ?? 0)) hrs", icon: "clock.fill", color: ColorTheme.accentCyan)
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    func statRow(label: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 20 : 24))
                .foregroundColor(color)
                .frame(width: isCompact ? 30 : 35)
            
            Text(label)
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: isCompact ? 18 : 20, weight: .bold, design: .monospaced))
                .foregroundColor(ColorTheme.textPrimary)
        }
    }
    
    var relapseCounter: some View {
        VStack(spacing: 10) {
            Text("Today's Relapses")
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
            
            Text("\(dataService.sobrietyData?.getTodayRelapseCount() ?? 0)")
                .font(.system(size: isCompact ? 48 : 60, weight: .bold, design: .monospaced))
                .foregroundColor((dataService.sobrietyData?.getTodayRelapseCount() ?? 0) == 0 ? ColorTheme.successGreen : ColorTheme.warningOrange)
                .glowEffect(color: (dataService.sobrietyData?.getTodayRelapseCount() ?? 0) == 0 ? ColorTheme.successGreen : ColorTheme.warningOrange, radius: 10)
            
            Text("Keep it up!")
                .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                .foregroundColor(ColorTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(isCompact ? 25 : 30)
        .futuristicCard()
    }
}

#Preview {
    ProfileView()
        .environmentObject(DataService())
}