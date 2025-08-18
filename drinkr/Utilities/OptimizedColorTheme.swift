import SwiftUI

extension View {
    func lightGlow(color: Color = ColorTheme.accentCyan, radius: CGFloat = 10) -> some View {
        self
            .shadow(color: color.opacity(0.4), radius: radius * 0.5)
    }
    
    func optimizedCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
    }
    
    func simpleShadow() -> some View {
        self
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}