import SwiftUI

struct OnboardingNameView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isVisible = false
    @FocusState private var isTextFieldFocused: Bool
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: isCompact ? 25 : 35) {
                // Header
                VStack(spacing: 15) {
                    Text("What should we call you?")
                        .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .offset(y: isVisible ? 0 : -20)
                    
                    Text("We'd love to personalize your journey with your name")
                        .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        .foregroundColor(ColorTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .offset(y: isVisible ? 0 : -15)
                }
                .padding(.top, isCompact ? 40 : 60)
                
                // Name input section
                VStack(spacing: 20) {
                    // Name input field
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(ColorTheme.accentCyan)
                            
                            Text("Your name")
                                .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        TextField("Enter your name", text: $viewModel.userName)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: isCompact ? 18 : 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                isTextFieldFocused ? ColorTheme.accentCyan : Color.white.opacity(0.2),
                                                lineWidth: isTextFieldFocused ? 2 : 1
                                            )
                                    )
                            )
                            .focused($isTextFieldFocused)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                    }
                    .padding(.horizontal, 20)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .offset(y: isVisible ? 0 : 20)
                    
                    // Encouragement message
                    if !viewModel.userName.isEmpty {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(ColorTheme.accentPink)
                                
                                Text("Nice to meet you, \(viewModel.userName)!")
                                    .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("We're honored to be part of your journey to freedom")
                                .font(.system(size: isCompact ? 14 : 16))
                                .foregroundColor(ColorTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [ColorTheme.accentPink.opacity(0.1), ColorTheme.accentCyan.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(ColorTheme.accentPink.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .scaleEffect(viewModel.userName.isEmpty ? 0.95 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.userName.isEmpty)
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                isVisible = true
            }
            
            // Auto-focus the text field after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
        .onDisappear {
            isVisible = false
            isTextFieldFocused = false
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            if isTextFieldFocused {
                isTextFieldFocused = false
            }
        }
    }
}

#Preview {
    ZStack {
        OptimizedBackground()
            .ignoresSafeArea()
        
        OnboardingNameView(viewModel: OnboardingViewModel())
    }
}