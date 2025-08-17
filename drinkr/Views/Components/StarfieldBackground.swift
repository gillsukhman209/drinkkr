import SwiftUI

struct StarfieldBackground: View {
    @State private var animatedStars: [AnimatedStar] = []
    
    var body: some View {
        ZStack {
            // Base gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.02, green: 0.05, blue: 0.15),  // Dark navy
                    Color(red: 0.08, green: 0.12, blue: 0.25),  // Slightly lighter navy
                    Color(red: 0.02, green: 0.05, blue: 0.15)   // Back to dark
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated stars
            ForEach(animatedStars, id: \.id) { star in
                Circle()
                    .fill(Color.white.opacity(star.opacity))
                    .frame(width: star.size, height: star.size)
                    .position(x: star.x, y: star.y)
                    .blur(radius: star.blur)
                    .animation(
                        Animation.easeInOut(duration: star.duration)
                            .repeatForever(autoreverses: true),
                        value: star.opacity
                    )
            }
        }
        .onAppear {
            generateStars()
        }
    }
    
    private func generateStars() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        animatedStars = (0..<150).map { _ in
            AnimatedStar(
                id: UUID(),
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: 0...screenHeight),
                size: CGFloat.random(in: 0.5...2.5),
                opacity: Double.random(in: 0.1...0.8),
                blur: CGFloat.random(in: 0...1),
                duration: Double.random(in: 2...6)
            )
        }
    }
}

struct AnimatedStar {
    let id: UUID
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
    let blur: CGFloat
    let duration: Double
}