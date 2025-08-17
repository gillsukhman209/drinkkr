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
├── ContentView.swift (Tab navigation)
├── Views/
│   ├── Dashboard/
│   │   └── DashboardView.swift ✅
│   ├── Profile/
│   │   └── ProfileView.swift ✅
│   ├── Library/
│   │   └── LibraryView.swift ✅
│   ├── Chat/
│   │   └── ChatView.swift ✅
│   ├── Menu/
│   │   └── MenuView.swift ✅
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

## Completed Features (Phase 1-3)
- ✅ Tab-based navigation with 5 tabs (Home, Library, Stats, Chat, Menu)
- ✅ Dark futuristic theme with navy/purple gradients
- ✅ Responsive design for all iOS device sizes
- ✅ Dashboard with real-time timer and crystal animation
- ✅ Profile/Stats view with real streak tracking
- ✅ Library view with educational content placeholders
- ✅ Chat view for community support
- ✅ Menu/Settings view with options
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

## Future Roadmap
- Apple Watch companion app
- Advanced analytics & statistics
- Community engagement features
- AI-powered craving journaling