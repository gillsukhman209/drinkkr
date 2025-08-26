import SwiftUI

struct PanicButtonModal: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var dataService: DataService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var currentStep = 0
    @State private var showingCongratulations = false
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    let cravingSteps = [
        CravingStep(
            title: "What's happening?",
            subtitle: nil,
            description: nil,
            icon: "questionmark.circle",
            actionText: "I feel like drinking",
            alternativeText: "I'm feeling better",
            image: "doctor_thinking",
            foods: nil
        ),
        CravingStep(
            title: "Try drinking water first",
            subtitle: "Have 2 glasses of water slowly",
            description: "Dehydration can intensify cravings. Your brain might be asking for fluids.",
            icon: "drop.fill",
            actionText: "I drank some water",
            alternativeText: "I'm feeling better",
            image: nil,
            foods: nil
        ),
        CravingStep(
            title: "Let's get your body moving",
            subtitle: nil,
            description: "Physical activity releases endorphins and changes your mental state.",
            icon: "figure.walk",
            actionText: "I moved my body",
            alternativeText: "I'm feeling better",
            image: "doctor_thinking",
            foods: nil
        ),
        CravingStep(
            title: "Try eating something satisfying",
            subtitle: "Choose protein-rich foods to stabilize blood sugar",
            description: nil,
            icon: nil,
            actionText: "I ate something",
            alternativeText: "I'm feeling better",
            image: nil,
            foods: [
                ("Nuts & Seeds", "🥜"),
                ("Cheese & Crackers", "🧀"),
                ("Greek Yogurt", "🥛"),
                ("Hard-boiled Eggs", "🥚"),
                ("Hummus & Veggies", "🥕"),
                ("Peanut Butter Toast", "🥜")
            ]
        ),
        CravingStep(
            title: "How are you feeling now?",
            subtitle: nil,
            description: nil,
            icon: "magnifyingglass",
            actionText: "Much better!",
            alternativeText: "I still want to drink",
            image: "doctor_magnifying",
            foods: nil
        ),
        CravingStep(
            title: "What's triggering this urge?",
            subtitle: nil,
            description: nil,
            icon: "brain.head.profile",
            actionText: "Stress or anxiety",
            alternativeText: "Boredom or habit",
            image: "doctor_thinking",
            foods: nil
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                if showingCongratulations {
                    congratulationsView
                } else if currentStep < cravingSteps.count {
                    stepView(cravingSteps[currentStep])
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func stepView(_ step: CravingStep) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                .padding()
                
                Spacer()
                
                if currentStep > 0 {
                    Button(action: {
                        // Help button action
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            // Content
            VStack(spacing: isCompact ? 30 : 40) {
                VStack(spacing: 16) {
                    Text(step.title)
                        .font(.system(size: isCompact ? 28 : 32, weight: .bold))
                        .foregroundColor(Color(red: 0.06, green: 0.2, blue: 0.4))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if let subtitle = step.subtitle {
                        Text(subtitle)
                            .font(.system(size: isCompact ? 16 : 18))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                // Visual content based on step
                if currentStep == 1 {
                    waterGlassVisual
                } else if currentStep == 3, let foods = step.foods {
                    foodGrid(foods)
                } else if step.image != nil {
                    doctorIllustration
                }
                
                if let description = step.description {
                    Text(description)
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
            }
            
            Spacer()
            
            // Buttons
            VStack(spacing: 20) {
                Button(action: {
                    handlePrimaryAction()
                }) {
                    Text(step.actionText)
                        .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, isCompact ? 16 : 20)
                        .background(Color(red: 0.0, green: 0.48, blue: 1.0))
                        .cornerRadius(30)
                }
                
                if let alternativeText = step.alternativeText {
                    Button(action: {
                        if currentStep == 4 && alternativeText == "I still want to drink" {
                            // Go to trigger identification
                            currentStep = 5
                        } else if currentStep == 5 {
                            // Any trigger option leads to congratulations
                            showingCongratulations = true
                        } else if alternativeText == "I'm feeling better" {
                            // Most "feeling better" options close modal
                            showingCongratulations = true
                        } else {
                            showingCongratulations = true
                        }
                    }) {
                        Text(alternativeText)
                            .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    var waterGlassVisual: some View {
        VStack(spacing: 20) {
            Image("doctor_water") // We'll use a system image as placeholder
                .resizable()
                .scaledToFit()
                .frame(height: isCompact ? 150 : 200)
                .overlay(
                    // Placeholder visual
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 0.06, green: 0.2, blue: 0.4), lineWidth: 3)
                                .frame(width: 80, height: 120)
                            
                            Rectangle()
                                .fill(Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.6))
                                .frame(width: 74, height: 80)
                                .offset(y: 17)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                        }
                        
                        Image(systemName: "drop.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
                            .offset(y: 20)
                    }
                )
        }
    }
    
    func foodGrid(_ foods: [(String, String)]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(foods, id: \.0) { food in
                VStack(spacing: 12) {
                    Text(food.1)
                        .font(.system(size: 44))
                    
                    Text(food.0)
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(15)
            }
        }
        .padding(.horizontal, 30)
    }
    
    var doctorIllustration: some View {
        // Placeholder doctor illustration
        VStack {
            Image(systemName: "figure.stand")
                .font(.system(size: 100))
                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
            
            Image(systemName: "stethoscope")
                .font(.system(size: 40))
                .foregroundColor(Color(red: 0.06, green: 0.2, blue: 0.4))
                .offset(y: -20)
        }
        .padding(.vertical, 40)
    }
    
    var congratulationsView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Congratulations!")
                    .font(.system(size: isCompact ? 32 : 36, weight: .bold))
                    .foregroundColor(Color(red: 0.0, green: 0.6, blue: 0.4))
                
                Text("You are awesome! 💪")
                    .font(.system(size: isCompact ? 24 : 28, weight: .semibold))
                    .foregroundColor(Color(red: 0.06, green: 0.2, blue: 0.4))
                
                Text("You didn't drink!")
                    .font(.system(size: isCompact ? 16 : 18))
                    .foregroundColor(.gray)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.0, green: 0.6, blue: 0.4))
                    .padding()
                
                Text("Next urge becomes easier ✨")
                    .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                    .foregroundColor(Color(red: 0.06, green: 0.2, blue: 0.4))
            }
            
            // Celebration visual
            doctorCelebrating
            
            Spacer()
            
            Button(action: {
                isPresented = false
            }) {
                Text("Continue")
                    .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                    .foregroundColor(Color(red: 0.06, green: 0.2, blue: 0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isCompact ? 16 : 20)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(30)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .background(
            // Confetti effect background
            GeometryReader { geometry in
                ForEach(0..<20) { index in
                    ConfettiPiece()
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
            }
        )
    }
    
    var doctorCelebrating: some View {
        VStack {
            Image(systemName: "figure.stand")
                .font(.system(size: 100))
                .foregroundColor(Color(red: 0.0, green: 0.48, blue: 1.0))
            
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(-15))
                
                Image(systemName: "star.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.yellow)
                    .offset(y: -10)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(15))
            }
            .offset(y: -20)
        }
    }
    
    
    func handlePrimaryAction() {
        if currentStep == 4 {
            // After "How are you feeling?" -> "Much better!" leads to congratulations
            showingCongratulations = true
        } else if currentStep == 5 {
            // After "What's triggering you?" -> any option leads to congratulations
            showingCongratulations = true
        } else if currentStep < cravingSteps.count - 1 {
            // Steps 0-3: continue to next step
            currentStep += 1
        } else {
            showingCongratulations = true
        }
    }
}

struct CravingStep {
    let title: String
    let subtitle: String?
    let description: String?
    let icon: String?
    let actionText: String
    let alternativeText: String?
    let image: String?
    let foods: [(String, String)]?
}

struct ConfettiPiece: View {
    @State private var animate = false
    let color = [Color.green, Color.blue, Color.purple, Color.pink, Color.orange].randomElement()!
    let shape = ["circle", "square", "star"].randomElement()!
    
    var body: some View {
        Group {
            if shape == "circle" {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
            } else if shape == "square" {
                Rectangle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            } else {
                Image(systemName: "star.fill")
                    .foregroundColor(color)
                    .font(.system(size: 12))
            }
        }
        .opacity(animate ? 0 : 0.8)
        .scaleEffect(animate ? 0.1 : 1)
        .offset(y: animate ? 100 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: Double.random(in: 1...3)).delay(Double.random(in: 0...1))) {
                animate = true
            }
        }
    }
}

#Preview {
    PanicButtonModal(isPresented: .constant(true))
        .environmentObject(DataService())
}