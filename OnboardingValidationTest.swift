import SwiftUI

// Test script to verify onboarding validation fix
struct OnboardingValidationTest: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Onboarding Validation Test")
                .font(.largeTitle)
                .bold()
            
            Text("Current Page: \(viewModel.currentPage)")
            Text("Can Proceed: \(viewModel.canProceed ? "✅" : "❌")")
            
            // Test different page validations
            Group {
                Button("Test Age Selection") {
                    viewModel.currentPage = .basics
                    viewModel.selectedAge = OnboardingQuestions.ageOptions.first
                    
                    // Should enable button after selection
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("After age selection - canProceed: \(viewModel.canProceed)")
                    }
                }
                
                Button("Test Gender Selection") {
                    viewModel.selectedGender = OnboardingQuestions.genderOptions.first
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("After gender selection - canProceed: \(viewModel.canProceed)")
                    }
                }
                
                Button("Test Why Here Selection") {
                    viewModel.currentPage = .whyHere  
                    viewModel.selectedWhyHere = OnboardingQuestions.whyHere.options.first
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("After why here selection - canProceed: \(viewModel.canProceed)")
                    }
                }
                
                Button("Test Multi-Select") {
                    viewModel.currentPage = .symptoms
                    viewModel.selectedSymptoms.insert(OnboardingQuestions.symptoms.options.first!)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("After symptoms selection - canProceed: \(viewModel.canProceed)")
                    }
                }
            }
            
            Spacer()
            
            Button("Start Real Onboarding Test") {
                // This would launch the actual onboarding
                print("Starting onboarding flow test...")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    OnboardingValidationTest()
}