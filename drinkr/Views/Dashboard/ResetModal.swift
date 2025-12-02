import SwiftUI

struct ResetModal: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var dataService: DataService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedTrigger = ""
    @State private var customTrigger = ""
    @State private var notes = ""
    @State private var showingConfirmation = false
    @State private var isTextFieldFocused = false
    
    let commonTriggers = [
        "Social pressure",
        "Stress at work",
        "Loneliness",
        "Celebration",
        "Bad news",
        "Boredom",
        "Anxiety",
        "Other"
    ]
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            ColorTheme.backgroundGradient
                .ignoresSafeArea()
            
            if showingConfirmation {
                confirmationView
            } else {
                resetFormView
            }
        }
    }
    
    var resetFormView: some View {
        ScrollView {
            VStack(spacing: isCompact ? 20 : 25) {
                headerView
                
                triggerSelection
                
                notesSection
                
                actionButtons
            }
            .padding(isCompact ? 20 : 30)
        }
    }
    
    var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: isCompact ? 50 : 60))
                .foregroundColor(ColorTheme.warningOrange)
                .glowEffect(color: ColorTheme.warningOrange, radius: 15)
            
            Text("Record Relapse")
                .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
            
            Text("It's okay to stumble. Let's learn from this.")
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    var triggerSelection: some View {
        VStack(spacing: 15) {
            Text("What triggered this relapse?")
                .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                .foregroundColor(ColorTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(commonTriggers, id: \.self) { trigger in
                    triggerButton(trigger)
                }
            }
            
            if selectedTrigger == "Other" {
                VStack(spacing: 10) {
                    Text("Please specify:")
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(ColorTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("What was the trigger?", text: $customTrigger)
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(ColorTheme.textPrimary)
                        .accentColor(ColorTheme.accentCyan)
                        .padding(12)
                        .background(ColorTheme.cardBackground)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isTextFieldFocused ? ColorTheme.accentCyan : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            isTextFieldFocused = true
                        }
                }
                .transition(.slide)
            }
        }
        .padding(isCompact ? 15 : 20)
        .futuristicCard()
    }
    
    func triggerButton(_ trigger: String) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTrigger = trigger
                if trigger != "Other" {
                    customTrigger = ""
                }
            }
        }) {
            Text(trigger)
                .font(.system(size: isCompact ? 12 : 14, weight: .medium))
                .foregroundColor(selectedTrigger == trigger ? .black : ColorTheme.textPrimary)
                .padding(.horizontal, isCompact ? 12 : 16)
                .padding(.vertical, isCompact ? 8 : 10)
                .frame(maxWidth: .infinity)
                .background(
                    selectedTrigger == trigger ?
                    AnyView(ColorTheme.warningOrange) :
                    AnyView(ColorTheme.cardBackground)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selectedTrigger == trigger ? Color.clear : ColorTheme.warningOrange.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var notesSection: some View {
        VStack(spacing: 15) {
            Text("Additional Notes (Optional)")
                .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                .foregroundColor(ColorTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("How were you feeling? What can help you next time?")
                .font(.system(size: isCompact ? 12 : 14))
                .foregroundColor(ColorTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextEditor(text: $notes)
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textPrimary)
                .scrollContentBackground(.hidden)
                .background(ColorTheme.cardBackground)
                .cornerRadius(10)
                .frame(height: isCompact ? 80 : 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(isCompact ? 15 : 20)
        .futuristicCard()
    }
    
    var actionButtons: some View {
        VStack(spacing: 15) {
            Button(action: {
                withAnimation(.spring()) {
                    showingConfirmation = true
                }
            }) {
                Text("Record Relapse")
                    .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(isCompact ? 15 : 18)
                    .background(ColorTheme.warningOrange)
                    .cornerRadius(15)
                    .glowEffect(color: ColorTheme.warningOrange, radius: 10)
            }
            .disabled(selectedTrigger.isEmpty || (selectedTrigger == "Other" && customTrigger.isEmpty))
            .opacity(selectedTrigger.isEmpty || (selectedTrigger == "Other" && customTrigger.isEmpty) ? 0.5 : 1.0)
            
            Button(action: {
                withAnimation(.spring()) {
                    isPresented = false
                }
            }) {
                Text("Cancel")
                    .font(.system(size: isCompact ? 16 : 18, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(isCompact ? 12 : 15)
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(ColorTheme.textSecondary.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }
    
    var confirmationView: some View {
        VStack(spacing: isCompact ? 25 : 35) {
            Image(systemName: "heart.fill")
                .font(.system(size: isCompact ? 60 : 80))
                .foregroundColor(ColorTheme.accentPink)
                .glowEffect(color: ColorTheme.accentPink, radius: 15)
            
            VStack(spacing: 15) {
                Text("We understand")
                    .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Text("Recovery isn't always linear. Every day is a new opportunity to start fresh.")
                    .font(.system(size: isCompact ? 16 : 18))
                    .foregroundColor(ColorTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 10) {
                    Text("Trigger: \(selectedTrigger == "Other" ? customTrigger : selectedTrigger)")
                        .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        .foregroundColor(ColorTheme.warningOrange)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(ColorTheme.warningOrange.opacity(0.2))
                        .cornerRadius(20)
                    
                    if !notes.isEmpty {
                        Text("Notes: \(notes)")
                            .font(.system(size: isCompact ? 12 : 14))
                            .foregroundColor(ColorTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 10)
            }
            
            VStack(spacing: 10) {
                Button(action: recordRelapse) {
                    Text("Reset My Journey")
                        .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(isCompact ? 15 : 18)
                        .background(ColorTheme.accentCyan)
                        .cornerRadius(15)
                        .glowEffect(color: ColorTheme.accentCyan, radius: 10)
                }
                
                Button(action: {
                    withAnimation(.spring()) {
                        showingConfirmation = false
                    }
                }) {
                    Text("Go Back")
                        .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                        .foregroundColor(ColorTheme.textSecondary)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding(isCompact ? 20 : 30)
    }
    
    func recordRelapse() {
        let trigger = selectedTrigger == "Other" ? customTrigger : selectedTrigger
        
        // Record the relapse first
        dataService.recordRelapse()
        
        // Then update the most recent relapse with trigger and notes
        if let relapse = dataService.cleanEatingData?.relapses.last {
            relapse.trigger = trigger
            relapse.notes = notes.isEmpty ? nil : notes
        }
        
        withAnimation(.spring()) {
            isPresented = false
        }
    }
}

#Preview {
    ResetModal(isPresented: .constant(true))
        .environmentObject(DataService())
}