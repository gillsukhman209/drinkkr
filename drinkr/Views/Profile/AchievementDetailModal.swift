import SwiftUI

struct AchievementDetailModal: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var dataService: DataService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedCategory: AchievementCategory = .streak
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    categoryPicker
                        .padding(.horizontal)
                        .padding(.top)
                    
                    achievementsList
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: 
                Button("Done") {
                    isPresented = false
                }
                .foregroundColor(ColorTheme.accentCyan)
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedCategory = category
                        }
                    }) {
                        Text(category.rawValue)
                            .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                            .foregroundColor(selectedCategory == category ? .black : ColorTheme.textPrimary)
                            .padding(.horizontal, isCompact ? 16 : 20)
                            .padding(.vertical, isCompact ? 8 : 10)
                            .background(
                                selectedCategory == category ?
                                AnyView(ColorTheme.accentCyan) :
                                AnyView(ColorTheme.cardBackground)
                            )
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedCategory == category ? Color.clear : ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 20)
    }
    
    var achievementsList: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(filteredAchievements, id: \.id) { achievement in
                    achievementCard(achievement)
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    var filteredAchievements: [Achievement] {
        return dataService.achievements.filter { $0.category == selectedCategory }
            .sorted { first, second in
                if first.isUnlocked != second.isUnlocked {
                    return first.isUnlocked
                }
                return first.progress > second.progress
            }
    }
    
    func achievementCard(_ achievement: Achievement) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? ColorTheme.successGreen.opacity(0.2) : ColorTheme.cardBackground)
                    .frame(width: isCompact ? 60 : 70, height: isCompact ? 60 : 70)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: isCompact ? 24 : 28))
                    .foregroundColor(achievement.isUnlocked ? ColorTheme.accentCyan : ColorTheme.textSecondary)
                    .glowEffect(color: achievement.isUnlocked ? ColorTheme.accentCyan : Color.clear, radius: 5)
            }
            
            VStack(spacing: 6) {
                Text(achievement.title)
                    .font(.system(size: isCompact ? 14 : 16, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(achievement.achievementDescription)
                    .font(.system(size: isCompact ? 11 : 12))
                    .foregroundColor(ColorTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            VStack(spacing: 8) {
                if achievement.isUnlocked {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ColorTheme.successGreen)
                            .font(.system(size: 12))
                        
                        Text("Unlocked")
                            .font(.system(size: isCompact ? 11 : 12, weight: .semibold))
                            .foregroundColor(ColorTheme.successGreen)
                    }
                    
                    if let dateEarned = achievement.dateEarned {
                        Text(formatDate(dateEarned))
                            .font(.system(size: isCompact ? 10 : 11))
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                } else {
                    VStack(spacing: 4) {
                        ProgressView(value: achievement.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: ColorTheme.accentPurple))
                            .scaleEffect(0.9)
                        
                        Text("\(achievement.currentValue)/\(achievement.requiredValue)")
                            .font(.system(size: isCompact ? 10 : 11, weight: .medium))
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(isCompact ? 16 : 20)
        .background(
            achievement.isUnlocked ? 
            ColorTheme.successGreen.opacity(0.1) : 
            ColorTheme.cardBackground
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    achievement.isUnlocked ? 
                    ColorTheme.successGreen.opacity(0.3) : 
                    ColorTheme.textSecondary.opacity(0.2), 
                    lineWidth: 1
                )
        )
        .scaleEffect(achievement.isUnlocked ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: achievement.isUnlocked)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    AchievementDetailModal(isPresented: .constant(true))
        .environmentObject(DataService())
}