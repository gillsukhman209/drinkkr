import SwiftUI

struct OptimizedBackground: View {
    var body: some View {
        // TRULY static gradient - no animations at all
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.02, green: 0.05, blue: 0.15),
                Color(red: 0.08, green: 0.12, blue: 0.25),
                Color(red: 0.02, green: 0.05, blue: 0.15)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct StaticStarfield: View {
    let stars: [Star] = {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        return (0..<50).map { _ in  // Reduced from 150 to 50
            Star(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: 0...screenHeight),
                size: CGFloat.random(in: 0.5...2),
                opacity: Double.random(in: 0.2...0.6)
            )
        }
    }()
    
    var body: some View {
        Canvas { context, size in
            for star in stars {
                let rect = CGRect(x: star.x, y: star.y, width: star.size, height: star.size)
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(star.opacity)))
            }
        }
        .allowsHitTesting(false)
    }
}

struct Star {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
}