import SwiftUI

struct ContentDetailView: View {
    let item: LibraryItem
    @Binding var isPresented: Bool
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isLoaded = false
    @State private var hasError = false
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                OptimizedBackground()
                    .ignoresSafeArea()
                
                if !isLoaded {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(ColorTheme.accentCyan)
                        
                        Text("Loading \(item.title)...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(ColorTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if hasError {
                    // Error state
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(ColorTheme.dangerRed)
                        
                        Text("Unable to load content")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        Text("Please try again or select a different article.")
                            .font(.system(size: 14))
                            .foregroundColor(ColorTheme.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            loadContent()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(ColorTheme.accentCyan)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    // Content loaded successfully
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header
                            headerView
                                .padding(.horizontal)
                                .padding(.top)
                            
                            // Content
                            contentView
                                .padding(.horizontal)
                            
                            Spacer(minLength: 50)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(ColorTheme.accentCyan)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadContent()
        }
    }
    
    var headerView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top, spacing: 15) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(ColorTheme.accentPurple.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(ColorTheme.accentPurple)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.category.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(ColorTheme.accentCyan)
                        .tracking(1.2)
                    
                    Text(item.duration)
                        .font(.system(size: 14))
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 12))
                        Text("Read Time")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(ColorTheme.textSecondary.opacity(0.8))
                }
                
                Spacer()
            }
            
            Text(item.title)
                .font(.system(size: isCompact ? 26 : 32, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
                .background(ColorTheme.accentCyan.opacity(0.3))
        }
        .padding(isCompact ? 20 : 25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(ColorTheme.accentCyan.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    var contentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(item.content.components(separatedBy: "\n\n"), id: \.self) { paragraph in
                if !paragraph.isEmpty {
                    if paragraph.hasPrefix("•") {
                        // Bullet point
                        HStack(alignment: .top, spacing: 10) {
                            Text("•")
                                .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                                .foregroundColor(ColorTheme.accentCyan)
                            
                            Text(paragraph.dropFirst(1).trimmingCharacters(in: .whitespaces))
                                .font(.system(size: isCompact ? 16 : 18))
                                .foregroundColor(ColorTheme.textPrimary)
                                .lineSpacing(8)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.leading, 10)
                    } else {
                        // Regular paragraph
                        Text(paragraph)
                            .font(.system(size: isCompact ? 16 : 18))
                            .foregroundColor(ColorTheme.textPrimary)
                            .lineSpacing(8)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(isCompact ? 20 : 25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(ColorTheme.textSecondary.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    func loadContent() {
        // Reset states
        hasError = false
        isLoaded = false
        
        // Simulate content loading with validation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Validate that we have valid content
            if !item.title.isEmpty && !item.content.isEmpty {
                withAnimation(.easeIn(duration: 0.3)) {
                    isLoaded = true
                }
            } else {
                withAnimation(.easeIn(duration: 0.3)) {
                    hasError = true
                }
            }
        }
    }
}