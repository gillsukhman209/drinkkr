import SwiftUI

struct PanicButtonModal: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var dataService: DataService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedTab = 0
    @State private var showingMeditation = false
    
    
    let affirmations = [
        "This feeling will pass. You are stronger than this craving.",
        "You have overcome challenges before, and you will overcome this one.",
        "Every moment you resist is a victory worth celebrating.",
        "You are choosing your health and future over temporary relief.",
        "This craving cannot control you. You have the power to choose.",
        "You are not alone in this journey. You have support and strength.",
        "Focus on why you started. Your reasons are still valid.",
        "This too shall pass. Stay strong and keep moving forward."
    ]
    
    let distractionActivities = [
        ("Take a Cold Shower", "snowflake", "Shock your system and reset your mindset"),
        ("Call Someone", "phone.fill", "Reach out to a friend, family member, or sponsor"),
        ("Go for a Walk", "figure.walk", "Get moving and change your environment"),
        ("Listen to Music", "music.note", "Put on your favorite uplifting playlist"),
        ("Deep Clean", "sparkles", "Channel energy into organizing your space"),
        ("Write It Out", "pencil", "Journal about what you're feeling right now"),
        ("Watch Comedy", "theatermasks.fill", "Find something that makes you laugh"),
        ("Exercise", "dumbbell.fill", "Do pushups, yoga, or any physical activity")
    ]
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                        .padding(.top)
                    
                    tabSelector
                        .padding(.horizontal)
                    
                    tabContent
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingMeditation) {
            MeditationModal(isPresented: $showingMeditation)
                .environmentObject(dataService)
        }
    }
    
    var headerView: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            
            Image(systemName: "heart.circle.fill")
                .font(.system(size: isCompact ? 50 : 60))
                .foregroundColor(ColorTheme.dangerRed)
                .glowEffect(color: ColorTheme.dangerRed, radius: 15)
            
            Text("We're Here for You")
                .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
            
            Text("You're not alone. Let's get through this together.")
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                let titles = ["Breathe", "Distract", "Affirm"]
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTab = index
                    }
                }) {
                    Text(titles[index])
                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                        .foregroundColor(selectedTab == index ? .black : ColorTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, isCompact ? 12 : 15)
                        .background(
                            selectedTab == index ?
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
        .padding(.vertical, 20)
    }
    
    var tabContent: some View {
        TabView(selection: $selectedTab) {
            breathingTab.tag(0)
            distractionTab.tag(1)
            affirmationTab.tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    var breathingTab: some View {
        VStack(spacing: isCompact ? 25 : 35) {
            Text("Guided Breathing")
                .font(.system(size: isCompact ? 20 : 24, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
            
            Text("Follow our advanced breathing pattern to calm your mind and body with haptic feedback")
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                Image(systemName: "wind")
                    .font(.system(size: isCompact ? 40 : 50))
                    .foregroundColor(ColorTheme.accentCyan)
                    .padding(.bottom, 10)
                
                Text("• Visual breathing guide")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Text("• Haptic feedback vibration")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Text("• Choose your duration")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(ColorTheme.textPrimary)
            }
            .padding(20)
            .futuristicCard()
            
            Button(action: {
                showingMeditation = true
            }) {
                Text("Start Breathing Exercise")
                    .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(isCompact ? 15 : 18)
                    .background(ColorTheme.accentCyan)
                    .cornerRadius(15)
                    .glowEffect(color: ColorTheme.accentCyan, radius: 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    var distractionTab: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Distraction Activities")
                    .font(.system(size: isCompact ? 20 : 24, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                    .padding(.bottom, 10)
                
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                    ForEach(distractionActivities, id: \.0) { activity in
                        distractionCard(title: activity.0, icon: activity.1, description: activity.2)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    func distractionCard(title: String, icon: String, description: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 24 : 28))
                .foregroundColor(ColorTheme.accentPurple)
                .frame(width: isCompact ? 40 : 50)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Text(description)
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
    
    var affirmationTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Positive Affirmations")
                    .font(.system(size: isCompact ? 20 : 24, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                    .padding(.bottom, 10)
                
                ForEach(affirmations, id: \.self) { affirmation in
                    affirmationCard(affirmation)
                }
            }
            .padding(.vertical)
        }
    }
    
    func affirmationCard(_ text: String) -> some View {
        VStack(spacing: 15) {
            Image(systemName: "quote.bubble.fill")
                .font(.system(size: isCompact ? 24 : 28))
                .foregroundColor(ColorTheme.accentPink)
            
            Text(text)
                .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                .foregroundColor(ColorTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
}

#Preview {
    PanicButtonModal(isPresented: .constant(true))
        .environmentObject(DataService())
}