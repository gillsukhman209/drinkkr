import SwiftUI

struct ColorTheme {
    static let primaryGradient = LinearGradient(
        colors: [
            Color(red: 0.1, green: 0.1, blue: 0.3),
            Color(red: 0.2, green: 0.1, blue: 0.4),
            Color(red: 0.3, green: 0.2, blue: 0.5)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.05, blue: 0.15),
            Color(red: 0.1, green: 0.05, blue: 0.2),
            Color(red: 0.15, green: 0.1, blue: 0.25)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let accentCyan = Color(red: 0, green: 0.8, blue: 0.9)
    static let accentPurple = Color(red: 0.6, green: 0.4, blue: 1.0)
    static let accentPink = Color(red: 1.0, green: 0.4, blue: 0.8)
    
    static let cardBackground = Color(white: 0.15).opacity(0.3)
    static let cardBorder = Color(white: 0.3).opacity(0.3)
    static let textPrimary = Color.white
    static let textSecondary = Color.gray
    
    static let successGreen = Color(red: 0.2, green: 0.9, blue: 0.4)
    static let warningOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let dangerRed = Color(red: 1.0, green: 0.3, blue: 0.3)
}

extension View {
    func glowEffect(color: Color = ColorTheme.accentCyan, radius: CGFloat = 10) -> some View {
        self
            .shadow(color: color.opacity(0.6), radius: radius)
            .shadow(color: color.opacity(0.3), radius: radius * 2)
    }
    
    func futuristicCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.05),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        ColorTheme.accentCyan.opacity(0.2),
                                        ColorTheme.accentPurple.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}