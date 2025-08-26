import SwiftUI

struct ContentDetailView: View {
    let item: LibraryItem
    @Binding var isPresented: Bool
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                OptimizedBackground()
                    .ignoresSafeArea()
                
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
}