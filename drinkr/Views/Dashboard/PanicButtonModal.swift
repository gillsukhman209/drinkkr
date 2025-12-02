import SwiftUI

struct PanicButtonModal: View {
    @Binding var isPresented: Bool
    @Binding var showingMeditationModal: Bool
    @EnvironmentObject var dataService: DataService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var currentStep = 0
    @State private var selectedTrigger: String? = nil
    @State private var breathingProgress: CGFloat = 0
    @State private var breathCount = 0
    @State private var isBreathing = false
    @State private var pulseAnimation = false
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.1, green: 0.05, blue: 0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Content
                    ScrollView(showsIndicators: false) {
                        contentView
                            .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            startPulseAnimation()
        }
    }
    
    var headerView: some View {
        HStack {
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding()
            
            Spacer()
            
            // Progress dots
            if currentStep > 0 {
                HStack(spacing: 8) {
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(index <= currentStep ? Color.cyan : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        switch currentStep {
        case 0:
            acknowledgeStruggleView
        case 1:
            encouragementSlide1View
        case 2:
            encouragementSlide2View
        case 3:
            encouragementSlide3View
        case 4:
            identifyTriggerView
        case 5:
            triggerSpecificHelpView
        case 6:
            checkInView
        case 7:
            conclusionView
        default:
            EmptyView()
        }
    }
    
    // MARK: - Step 1: Stop What You're Doing
    var acknowledgeStruggleView: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)
            
            // Big warning text
            VStack(spacing: 16) {
                Text("STOP WHAT YOU'RE DOING")
                    .font(.system(size: isCompact ? 32 : 38, weight: .black))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .tracking(1)
                
                Text("Side effects of fast food:")
                    .font(.system(size: isCompact ? 18 : 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.bottom, 30)
            
            // Effects list
            VStack(spacing: 20) {
                effectItem(
                    icon: "bolt.slash.fill",
                    title: "ENERGY CRASH",
                    subtitle: "Sluggishness and brain fog that ruins your productivity and mood."
                )
                
                effectItem(
                    icon: "arrow.up.left.and.arrow.down.right",
                    title: "PHYSICAL BLOATING",
                    subtitle: "Feeling heavy, bloated, and uncomfortable in your own skin."
                )
                
                effectItem(
                    icon: "heart.slash.fill",
                    title: "HEALTH RISKS",
                    subtitle: "Increased risk of heart disease, diabetes, and long-term health issues."
                )
                
                effectItem(
                    icon: "arrow.counterclockwise",
                    title: "RESET YOUR PROGRESS",
                    subtitle: "Breaking your streak and undoing the healthy habits you've built."
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 40)
            
            // Continue button
            Button(action: {
                withAnimation(.spring()) {
                    currentStep = 1
                }
            }) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 16))
                    Text("I'm stopping myself")
                }
                .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [Color.green, Color.cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
            }
            .padding(.horizontal, 20)
            
            Spacer()
                .frame(height: 20)
        }
    }
    
    // MARK: - Step 2: Encouragement Slide 1
    var encouragementSlide1View: some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(height: 60)
            
            // Animated icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
            }
            
            VStack(spacing: 24) {
                Text("This craving will pass.")
                    .font(.system(size: isCompact ? 32 : 38, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("It always does.")
                    .font(.system(size: isCompact ? 24 : 28, weight: .semibold))
                    .foregroundColor(.orange)
                
                Text("Cravings peak in 3-5 minutes, then fade. You've survived 100% of your worst days so far. You can survive this one too.")
                    .font(.system(size: isCompact ? 16 : 18))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring()) {
                    currentStep = 2
                }
            }) {
                Text("I believe that")
                    .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Step 3: Encouragement Slide 2
    var encouragementSlide2View: some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(height: 60)
            
            // Animated icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.3), Color.purple.opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
            }
            
            VStack(spacing: 24) {
                Text("Your brain is lying to you.")
                    .font(.system(size: isCompact ? 32 : 38, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Fast food solves nothing.")
                    .font(.system(size: isCompact ? 24 : 28, weight: .semibold))
                    .foregroundColor(.purple)
                
                Text("It won't fix your stress or make you happy. It will only add bloating, regret, and reset your progress. The person you'll be tomorrow is counting on the choice you make right now.")
                    .font(.system(size: isCompact ? 16 : 18))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring()) {
                    currentStep = 3
                }
            }) {
                Text("My future self matters")
                    .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Step 4: Encouragement Slide 3
    var encouragementSlide3View: some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(height: 60)
            
            // Animated icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.green.opacity(0.3), Color.green.opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
            }
            
            VStack(spacing: 24) {
                Text("You are stronger than this craving.")
                    .font(.system(size: isCompact ? 30 : 36, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("You've already proven it.")
                    .font(.system(size: isCompact ? 24 : 28, weight: .semibold))
                    .foregroundColor(.green)
                
                Text("Every day you've eaten clean is proof of your strength. You didn't come this far just to come this far. Choose the version of yourself you're becoming, not the one you're leaving behind.")
                    .font(.system(size: isCompact ? 16 : 18))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring()) {
                    currentStep = 4
                }
            }) {
                Text("I choose strength")
                    .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Step 5: Identify Trigger
    var identifyTriggerView: some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(height: 40)
            
            VStack(spacing: 16) {
                Text("What triggered this craving?")
                    .font(.system(size: isCompact ? 26 : 30, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Understanding helps us address the root cause")
                    .font(.system(size: isCompact ? 16 : 18))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            // Trigger options
            VStack(spacing: 12) {
                triggerOption(icon: "cloud.bolt.fill", title: "Stress", subtitle: "Work, life, or pressure", color: .red)
                triggerOption(icon: "brain.head.profile", title: "Anxiety", subtitle: "Worry or nervousness", color: .purple)
                triggerOption(icon: "moon.zzz.fill", title: "Boredom", subtitle: "Nothing to do", color: .indigo)
                triggerOption(icon: "person.2.fill", title: "Social", subtitle: "Others eating junk food", color: .orange)
                triggerOption(icon: "clock.fill", title: "Habit", subtitle: "It's my usual time", color: .green)
                triggerOption(icon: "heart.slash.fill", title: "Emotional", subtitle: "Sadness or loneliness", color: .pink)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    // MARK: - Step 6: Trigger-Specific Help
    @ViewBuilder
    var triggerSpecificHelpView: some View {
        if let trigger = selectedTrigger {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Header
                    VStack(spacing: 12) {
                        Text(getTriggerTitle(trigger))
                            .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(getTriggerSubtitle(trigger))
                            .font(.system(size: isCompact ? 16 : 18))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    
                    // Specific strategies
                    VStack(spacing: 16) {
                        ForEach(getTriggerStrategies(trigger), id: \.self) { strategy in
                            strategyCard(strategy)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.spring()) {
                                currentStep = 6
                            }
                        }) {
                            Text("I tried these strategies")
                                .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.cyan, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                        }
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                currentStep = 6
                            }
                        }) {
                            Text("Skip to check-in")
                                .font(.system(size: isCompact ? 16 : 18))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
    }
    
    // MARK: - Step 7: Check-in
    var checkInView: some View {
        VStack(spacing: 40) {
            Spacer()
                .frame(height: 60)
            
            VStack(spacing: 20) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("How are you feeling now?")
                    .font(.system(size: isCompact ? 26 : 30, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Be honest with yourself")
                    .font(.system(size: isCompact ? 16 : 18))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 16) {
                Button(action: {
                    withAnimation(.spring()) {
                        currentStep = 7
                        // Log that user resisted craving (can implement later)
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "face.smiling.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        Text("The craving passed!")
                            .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                            .foregroundColor(.white)
                        Text("I don't want to eat junk anymore")
                            .font(.system(size: isCompact ? 14 : 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.green.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.green.opacity(0.5), lineWidth: 2)
                    )
                    .cornerRadius(20)
                }
                
                Button(action: {
                    // Go back to breathing or try different strategies
                    withAnimation(.spring()) {
                        currentStep = 1
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("Still struggling")
                            .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Let me try the exercises again")
                            .font(.system(size: isCompact ? 14 : 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.orange.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.orange.opacity(0.5), lineWidth: 2)
                    )
                    .cornerRadius(20)
                }
                
                Button(action: {
                    // Close panic modal and open meditation
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showingMeditationModal = true
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "lungs.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        Text("Take me to meditation")
                            .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Guided breathing exercise")
                            .font(.system(size: isCompact ? 14 : 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.blue.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                    )
                    .cornerRadius(20)
                }
                
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
    
    // MARK: - Step 8: Conclusion
    var conclusionView: some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(height: 60)
            
            // Success animation
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.green.opacity(0.3), Color.green.opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 150, height: 150)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
            }
            
            VStack(spacing: 20) {
                Text("You did it! 🎉")
                    .font(.system(size: isCompact ? 32 : 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("You just proved you're stronger than your cravings")
                    .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    statItem(icon: "flame.fill", text: "Craving defeated", color: .orange)
                    statItem(icon: "brain.head.profile", text: "New neural pathway strengthened", color: .purple)
                    statItem(icon: "chart.line.uptrend.xyaxis", text: "Next craving will be easier", color: .cyan)
                }
                .padding(.vertical, 20)
                
                Text("Remember: Every time you resist, you're literally rewiring your brain for success.")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
            
            Button(action: {
                isPresented = false
            }) {
                Text("Continue my day")
                    .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Helper Views
    func breathingStep(number: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(number)
                .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    func triggerOption(icon: String, title: String, subtitle: String, color: Color) -> some View {
        Button(action: {
            selectedTrigger = title
            withAnimation(.spring()) {
                currentStep = 5
            }
            impactFeedback(.light)
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
        }
    }
    
    func strategyCard(_ strategy: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.cyan)
            
            Text(strategy)
                .font(.system(size: isCompact ? 16 : 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
    }
    
    func effectItem(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.red)
                .frame(width: 30, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: isCompact ? 16 : 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.red.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
    
    func statItem(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - Helper Functions
    func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
    
    
    func getTriggerTitle(_ trigger: String) -> String {
        switch trigger {
        case "Stress": return "Let's manage this stress"
        case "Anxiety": return "Let's calm your anxiety"
        case "Boredom": return "Let's beat this boredom"
        case "Social": return "Handling social pressure"
        case "Habit": return "Breaking the habit loop"
        case "Emotional": return "Processing these emotions"
        default: return "Let's work through this"
        }
    }
    
    func getTriggerSubtitle(_ trigger: String) -> String {
        switch trigger {
        case "Stress": return "Alcohol won't solve the problem, it will add to it"
        case "Anxiety": return "Alcohol increases anxiety tomorrow for temporary relief today"
        case "Boredom": return "Your brain is seeking stimulation - let's give it something healthy"
        case "Social": return "You don't need alcohol to be social or have fun"
        case "Habit": return "This is just your brain's old programming - we can override it"
        case "Emotional": return "Feelings are temporary, but drinking consequences last"
        default: return "You've got this"
        }
    }
    
    func getTriggerStrategies(_ trigger: String) -> [String] {
        switch trigger {
        case "Stress":
            return [
                "Take 10 deep breaths right now",
                "Write down 3 things stressing you out",
                "Do 20 jumping jacks to release tension",
                "Call or text someone you trust",
                "Take a 5-minute walk outside"
            ]
        case "Anxiety":
            return [
                "Use the 5-4-3-2-1 grounding technique",
                "Put on calming music or nature sounds",
                "Practice progressive muscle relaxation",
                "Write your worries in a journal",
                "Do gentle stretching for 5 minutes"
            ]
        case "Boredom":
            return [
                "Start that show you've been meaning to watch",
                "Play a mobile game for 10 minutes",
                "Clean or organize one small area",
                "Learn something new on YouTube",
                "Text a friend you haven't talked to recently"
            ]
        case "Social":
            return [
                "Have a non-alcoholic drink in hand",
                "Prepare your 'not drinking' response",
                "Find the other non-drinkers",
                "Have an exit plan ready",
                "Remember: real friends support your choice"
            ]
        case "Habit":
            return [
                "Change your environment right now",
                "Make a cup of tea or coffee",
                "Brush your teeth (changes taste)",
                "Do something with your hands",
                "Go to a different room"
            ]
        case "Emotional":
            return [
                "Let yourself feel the emotion fully",
                "Cry if you need to - it's healing",
                "Write an unsent letter to express feelings",
                "Listen to music that matches your mood",
                "Practice self-compassion phrases"
            ]
        default:
            return ["Take it one moment at a time"]
        }
    }
    
    // MARK: - Haptic Feedback
    private func impactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    private func notificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

#Preview {
    PanicButtonModal(isPresented: .constant(true), showingMeditationModal: .constant(false))
        .environmentObject(DataService())
}