# Claude Instructions for Drinkr iOS App

## Overview
Drinkr is an iOS app designed to help people quit alcohol. It provides a sobriety timer, streak tracking, relapse logging, panic button, reflection prompts, and an educational library. The app is built with SwiftUI and follows a dark navy/purple gradient design theme with smooth animations.

## Tech Stack
- Language: Swift
- UI: SwiftUI (no UIKit unless necessary)
- Data Storage: SwiftData for persistence, UserDefaults for lightweight settings
- Notifications: UserNotifications for daily pledges and reminders
- Cloud: CloudKit for sync/backup (future)
- Health: HealthKit integration (optional, future)

## Current File Structure
```
drinkr/
├── ContentView.swift (Tab navigation - 3 tabs)
├── Views/
│   ├── Dashboard/
│   │   └── DashboardView.swift ✅
│   ├── Profile/
│   │   └── ProfileView.swift ✅
│   ├── Library/
│   │   └── LibraryView.swift ✅ (renamed to "Learn")
│   └── Components/
│       └── (Crystal animation built-in)
├── Utilities/
│   └── ColorTheme.swift ✅
├── Models/
│   ├── User.swift (pending)
│   ├── SobrietyData.swift (pending)
│   └── Achievement.swift (pending)
└── Services/
    ├── NotificationService.swift (pending)
    └── DataService.swift (pending)
```

## Completed Features (Phase 1-4)
- ✅ Tab-based navigation with 3 tabs (Home, Stats, Learn)
- ✅ Modern starfield background with animated twinkling stars
- ✅ Responsive design for all iOS device sizes  
- ✅ Dashboard with smart timer display and glassmorphism UI
- ✅ Profile/Stats view with comprehensive progress tracking
- ✅ Learn view (formerly Library) with educational content
- ✅ Full data persistence with SwiftData
- ✅ Achievement system with progress tracking
- ✅ Functional action buttons with modals
- ✅ Notification scheduling for check-ins
- ✅ Meditation with guided breathing and haptic feedback
- ✅ Relapse tracking with trigger analysis
- ✅ Panic button with emergency help
- ✅ Milestone celebrations with animations

## Implementation Phases
1. ✅ Core Structure & Navigation - COMPLETED
2. ✅ Data Models & Storage - COMPLETED
   - User model with real data
   - SobrietyData model (quit date, relapse count, streak)
   - SwiftData + UserDefaults setup
3. ✅ Main Dashboard - COMPLETED
   - Connect to real data
   - Implement action button functionality
4. ✅ Profile/Progress Screen - COMPLETED
   - Enhanced ProfileView with comprehensive statistics
   - Real-time achievement progress tracking
   - Milestone countdown and celebration system
   - Relapse history and pattern analysis
   - Time-frame based statistics (All Time, Month, Week)
   - Achievement detail modal with progress indicators
   - Relapse history modal with trigger analysis
5. Panic Button Feature
   - Modal with breathing, affirmations, distraction, success stories
6. Reflection & Breathing
   - Daily prompts
   - Guided breathing exercises
   - Completion tracking
7. Educational Library
   - Real content integration
   - Search/filter functionality
8. Additional Features
   - Notifications for pledges
   - Milestone celebrations
   - Badge/achievement system
   - Home screen widget

## Design Guidelines
- Modern/futuristic aesthetic with glowing effects
- Responsive layouts using @Environment size classes
- isCompact property for adaptive sizing
- ColorTheme utility for consistent colors
- .futuristicCard() modifier for consistent card styling
- .glowEffect() modifier for accent elements

## Edge Cases Handled
- Different screen sizes (iPhone SE to iPad)
- Landscape/Portrait orientations
- Dark mode only (enforced)
- Empty states in chat and library
- Safe area handling
- Keyboard avoidance in chat

## Next Steps
Phase 2: Data Models & Storage implementation

## Coding Guidelines
- Use MVVM pattern for views
- Keep code modular and aligned with file structure above
- Do not delete placeholder views — expand them instead
- Use clear, descriptive variable names
- Default to dark navy/purple gradient theme
- Keep interfaces minimal and accessible

## Onboarding Flow (To Be Implemented)

### Overview
Emotionally-engaging onboarding that deeply understands user struggles with alcohol, building strong connection and motivation for change.

### Onboarding Structure:

#### 1. Welcome & Hook Screens (3-4 screens)
- "You're not alone. Let's take this journey together."
- "Every day without alcohol is a victory worth celebrating"
- "Join thousands who've reclaimed their lives"
- "Your personalized recovery path starts here"

#### 2. Emotional Connection Questions

**Q1: Why are you here today?**
- I want to quit completely
- I need to cut back
- Someone asked me to stop
- I'm just exploring
- I hit rock bottom

**Q2: How is alcohol affecting your life?** (Multiple select)
- Damaging my relationships
- Affecting my work/career
- Harming my health
- Causing financial stress
- Making me anxious/depressed
- Ruining my sleep
- Causing shame and guilt
- Missing important moments

**Q3: What symptoms are you experiencing?** (Multiple select)
- Morning shakes or tremors
- Constant fatigue
- Memory blackouts
- Anxiety when not drinking
- Trouble sleeping without alcohol
- Heart palpitations
- Sweating or hot flashes
- Mood swings
- Brain fog

**Q4: What have you lost to alcohol?** (Multiple select)
- Trust from loved ones
- Job opportunities
- Money and savings
- Self-respect
- Physical health
- Mental clarity
- Time with family
- Personal goals

**Q5: What triggers your drinking?** (Multiple select)
- Stress from work
- Social pressure
- Loneliness
- Boredom
- Celebrating
- Anger or frustration
- Sadness or depression
- Habit/routine
- Physical cravings

**Q6: How do you feel after drinking?**
- Ashamed and guilty
- Anxious and worried
- Physically sick
- Depressed
- Angry at myself
- Hopeless

**Q7: What's your biggest fear about quitting?**
- I'll lose my friends
- I can't handle stress without it
- Life will be boring
- I'll fail and disappoint everyone
- Withdrawal symptoms
- I don't know who I am without it

**Q8: Have you tried to quit before?**
- Never tried
- Once or twice
- Several times
- Many times
- I've lost count

#### 3. Data Collection Questions

**Q9: Your basics**
- Age range (18-24, 25-34, 35-44, 45-54, 55+)
- Gender (Male/Female/Other/Prefer not to say)
- Relationship status

**Q10: Your drinking pattern**
- How often do you drink? (Daily/Few times a week/Weekly/Occasionally)
- How many drinks per session? (1-2/3-4/5-6/7+)
- Preferred type? (Beer/Wine/Spirits/Mixed)

**Q11: The cost**
- Weekly spending on alcohol ($0-20/$20-50/$50-100/$100+)
- Hours per week lost to drinking/hangovers

#### 4. Hope & Motivation Screen
Personalized message based on answers:
- "You could save $[amount] per month"
- "You could reclaim [hours] hours per week"
- "Join [number] others who felt exactly like you"

#### 5. Goal Setting Screen
**What do you want to achieve?** (Multiple select)
- 🧠 Clear mind and better focus
- ❤️ Rebuild trust with loved ones
- 💪 Get healthy and fit
- 😴 Sleep peacefully
- 💰 Save money for dreams
- 🎯 Achieve my goals
- 😊 Find happiness without alcohol
- 🏆 Prove I can do this

#### 6. Commitment Screen
- "I'm ready to take control of my life"
- Set quit date (Today/Tomorrow/Choose date)
- Daily check-in time preference

#### 7. Support & Permissions
- Enable notifications
- Show success story quote
- "We'll be here every step of the way"

### User Profile Data Structure
```
UserProfile:
  // Emotional data
  - quittingReason: String
  - lifeImpacts: [String]
  - symptoms: [String]
  - losses: [String]
  - triggers: [String]
  - afterFeeling: String
  - biggestFear: String
  - previousAttempts: String
  
  // Practical data
  - age: String
  - gender: String
  - relationshipStatus: String
  - drinkingFrequency: String
  - drinksPerSession: Int
  - weeklySpending: Double
  - hoursLostWeekly: Int
  
  // Goals & Commitment
  - selectedGoals: [String]
  - quitDate: Date
  - checkInTime: Date
```

### Implementation Files Needed
1. OnboardingContainerView.swift - Main navigation with progress
2. OnboardingWelcomeView.swift - Welcome/hook screens
3. OnboardingEmotionalQuestions.swift - Emotional questions (Q1-Q8)
4. OnboardingDataQuestions.swift - Practical data (Q9-Q11)
5. OnboardingGoalsView.swift - Goal selection
6. OnboardingCommitmentView.swift - Quit date & commitment
7. OnboardingViewModel.swift - State management
8. OnboardingModels.swift - Data structures

### Key Emotional Hooks
- Acknowledgment: "We see your struggle"
- Hope: "Recovery is possible"
- Community: "You're not alone"
- Personalization: Tailored experience
- Small wins: "Every day matters"
- No judgment: "Safe space"

### Visual Design Notes
- Use OptimizedBackground for consistency
- Progress bar at top showing journey
- Gentle transitions between questions
- Multiple select with checkboxes
- Single select with radio buttons
- Empathetic color choices (soft blues/purples)
- Show % of users with similar selections for connection

## Future Roadmap
- Apple Watch companion app
- Advanced analytics & statistics
- Community engagement features
- AI-powered craving journaling