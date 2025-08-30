import Foundation
import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: OnboardingPage = .welcome
    @Published var userProfile = OnboardingUserProfile()
    @Published var isTransitioning = false
    @Published var showingDatePicker = false
    @Published var canProceed = false
    
    // Track selections for each question
    @Published var selectedWhyHere: OnboardingOption?
    @Published var selectedLifeImpacts: Set<OnboardingOption> = []
    @Published var selectedSymptoms: Set<OnboardingOption> = []
    @Published var selectedLosses: Set<OnboardingOption> = []
    @Published var selectedTriggers: Set<OnboardingOption> = []
    @Published var selectedAfterFeeling: OnboardingOption?
    @Published var selectedBiggestFear: OnboardingOption?
    @Published var selectedPreviousAttempts: OnboardingOption?
    @Published var userName: String = ""
    @Published var selectedDrinkingFrequency: OnboardingOption?
    @Published var selectedDrinksPerSession: OnboardingOption?
    @Published var selectedWeeklySpending: OnboardingOption?
    @Published var selectedHoursLost: OnboardingOption?
    @Published var selectedGoals: Set<OnboardingGoal> = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidation()
    }
    
    private func setupValidation() {
        // Monitor current page changes
        $currentPage
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        // Monitor all single selection fields
        $selectedWhyHere
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        $selectedAfterFeeling
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        $selectedBiggestFear
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        $selectedPreviousAttempts
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        $userName
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        
        $selectedDrinkingFrequency
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        $selectedDrinksPerSession
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        $selectedWeeklySpending
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        $selectedHoursLost
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        // Monitor multi-selection fields
        $selectedLifeImpacts
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        $selectedSymptoms
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        $selectedLosses
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        $selectedTriggers
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
        
        $selectedGoals
            .sink { [weak self] _ in 
                DispatchQueue.main.async {
                    self?.updateCanProceed()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateCanProceed() {
        switch currentPage {
        case .welcome, .intro1, .intro2, .intro3:
            canProceed = true
        case .whyHere:
            canProceed = selectedWhyHere != nil
        case .lifeImpact:
            canProceed = !selectedLifeImpacts.isEmpty
        case .symptoms:
            canProceed = !selectedSymptoms.isEmpty
        case .losses:
            canProceed = !selectedLosses.isEmpty
        case .triggers:
            canProceed = !selectedTriggers.isEmpty
        case .afterFeeling:
            canProceed = selectedAfterFeeling != nil
        case .biggestFear:
            canProceed = selectedBiggestFear != nil
        case .previousAttempts:
            canProceed = selectedPreviousAttempts != nil
        case .name:
            canProceed = !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .drinkingPattern:
            canProceed = selectedDrinkingFrequency != nil && selectedDrinksPerSession != nil
        case .cost:
            canProceed = selectedWeeklySpending != nil && selectedHoursLost != nil
        case .motivation:
            canProceed = true
        case .goals:
            canProceed = !selectedGoals.isEmpty
        case .commitment:
            canProceed = true
        case .complete:
            canProceed = true
        }
    }
    
    func nextPage() {
        guard canProceed else { return }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isTransitioning = true
        }
        
        // Save current page data to profile
        saveCurrentPageData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.moveToNextPage()
                self.isTransitioning = false
            }
        }
    }
    
    func previousPage() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isTransitioning = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.moveToPreviousPage()
                self.isTransitioning = false
            }
        }
    }
    
    private func moveToNextPage() {
        switch currentPage {
        case .welcome:
            currentPage = .intro1
        case .intro1:
            currentPage = .intro2
        case .intro2:
            currentPage = .intro3
        case .intro3:
            currentPage = .whyHere
        case .whyHere:
            currentPage = .lifeImpact
        case .lifeImpact:
            currentPage = .symptoms
        case .symptoms:
            currentPage = .losses
        case .losses:
            currentPage = .triggers
        case .triggers:
            currentPage = .afterFeeling
        case .afterFeeling:
            currentPage = .biggestFear
        case .biggestFear:
            currentPage = .previousAttempts
        case .previousAttempts:
            currentPage = .name
        case .name:
            currentPage = .drinkingPattern
        case .drinkingPattern:
            currentPage = .cost
        case .cost:
            currentPage = .motivation
        case .motivation:
            currentPage = .commitment
        case .goals:
            currentPage = .commitment
        case .commitment:
            currentPage = .complete
        case .complete:
            break
        }
    }
    
    private func moveToPreviousPage() {
        switch currentPage {
        case .welcome:
            break
        case .intro1:
            currentPage = .welcome
        case .intro2:
            currentPage = .intro1
        case .intro3:
            currentPage = .intro2
        case .whyHere:
            currentPage = .intro3
        case .lifeImpact:
            currentPage = .whyHere
        case .symptoms:
            currentPage = .lifeImpact
        case .losses:
            currentPage = .symptoms
        case .triggers:
            currentPage = .losses
        case .afterFeeling:
            currentPage = .triggers
        case .biggestFear:
            currentPage = .afterFeeling
        case .previousAttempts:
            currentPage = .biggestFear
        case .name:
            currentPage = .previousAttempts
        case .drinkingPattern:
            currentPage = .name
        case .cost:
            currentPage = .drinkingPattern
        case .motivation:
            currentPage = .cost
        case .goals:
            currentPage = .motivation
        case .commitment:
            currentPage = .motivation
        case .complete:
            currentPage = .commitment
        }
    }
    
    private func saveCurrentPageData() {
        switch currentPage {
        case .whyHere:
            userProfile.quittingReason = selectedWhyHere?.text ?? ""
        case .lifeImpact:
            userProfile.lifeImpacts = Array(selectedLifeImpacts).map { $0.text }
        case .symptoms:
            userProfile.symptoms = Array(selectedSymptoms).map { $0.text }
        case .losses:
            userProfile.losses = Array(selectedLosses).map { $0.text }
        case .triggers:
            userProfile.triggers = Array(selectedTriggers).map { $0.text }
        case .afterFeeling:
            userProfile.afterFeeling = selectedAfterFeeling?.text ?? ""
        case .biggestFear:
            userProfile.biggestFear = selectedBiggestFear?.text ?? ""
        case .previousAttempts:
            userProfile.previousAttempts = selectedPreviousAttempts?.text ?? ""
        case .name:
            userProfile.userName = userName
        case .drinkingPattern:
            userProfile.drinkingFrequency = selectedDrinkingFrequency?.text ?? ""
            userProfile.drinksPerSession = selectedDrinksPerSession?.text ?? ""
        case .cost:
            userProfile.weeklySpending = selectedWeeklySpending?.text ?? ""
            userProfile.hoursLostWeekly = selectedHoursLost?.text ?? ""
        case .goals:
            userProfile.selectedGoals = Array(selectedGoals).map { $0.title }
        default:
            break
        }
    }
    
    func completeOnboarding() {
        // Save final profile data
        saveUserProfile()
        
        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Notify completion
        NotificationCenter.default.post(name: .onboardingCompleted, object: userProfile)
    }
    
    private func saveUserProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "onboardingUserProfile")
        }
    }
    
    func loadUserProfile() -> OnboardingUserProfile? {
        if let data = UserDefaults.standard.data(forKey: "onboardingUserProfile"),
           let profile = try? JSONDecoder().decode(OnboardingUserProfile.self, from: data) {
            return profile
        }
        return nil
    }
    
    func canGoBack() -> Bool {
        return currentPage != .welcome
    }
    
    func skipToNameSlide() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentPage = .name
        }
    }
    
}

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}