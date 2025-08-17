import SwiftUI

struct LibraryView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    let categories = ["All", "Articles", "Videos", "Tips", "Stories"]
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    let libraryItems = [
        LibraryItem(title: "Understanding Alcohol Cravings", category: "Articles", duration: "5 min", icon: "doc.text.fill"),
        LibraryItem(title: "Success Story: John's Journey", category: "Stories", duration: "3 min", icon: "person.fill"),
        LibraryItem(title: "10 Ways to Stay Sober", category: "Tips", duration: "4 min", icon: "lightbulb.fill"),
        LibraryItem(title: "Meditation for Recovery", category: "Videos", duration: "15 min", icon: "play.circle.fill"),
        LibraryItem(title: "The Science of Addiction", category: "Articles", duration: "8 min", icon: "doc.text.fill"),
        LibraryItem(title: "Building Healthy Habits", category: "Tips", duration: "6 min", icon: "lightbulb.fill")
    ]
    
    var filteredItems: [LibraryItem] {
        libraryItems.filter { item in
            (selectedCategory == "All" || item.category == selectedCategory) &&
            (searchText.isEmpty || item.title.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                StarfieldBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    searchBar
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    categoryPicker
                        .padding(.vertical, 10)
                    
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredItems) { item in
                                libraryItemCard(item)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ColorTheme.textSecondary)
            
            TextField("Search library...", text: $searchText)
                .foregroundColor(ColorTheme.textPrimary)
                .accentColor(ColorTheme.accentCyan)
        }
        .padding(12)
        .background(ColorTheme.cardBackground)
        .cornerRadius(10)
    }
    
    var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    categoryChip(category)
                }
            }
            .padding(.horizontal)
        }
    }
    
    func categoryChip(_ category: String) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedCategory = category
            }
        }) {
            Text(category)
                .font(.system(size: isCompact ? 14 : 16, weight: .medium))
                .foregroundColor(selectedCategory == category ? .black : ColorTheme.textPrimary)
                .padding(.horizontal, isCompact ? 16 : 20)
                .padding(.vertical, isCompact ? 8 : 10)
                .background(
                    selectedCategory == category ?
                    AnyView(ColorTheme.accentCyan) :
                    AnyView(ColorTheme.cardBackground)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selectedCategory == category ? Color.clear : ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func libraryItemCard(_ item: LibraryItem) -> some View {
        HStack(spacing: 15) {
            Image(systemName: item.icon)
                .font(.system(size: isCompact ? 24 : 28))
                .foregroundColor(ColorTheme.accentPurple)
                .frame(width: isCompact ? 50 : 60, height: isCompact ? 50 : 60)
                .background(ColorTheme.accentPurple.opacity(0.2))
                .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                    .foregroundColor(ColorTheme.textPrimary)
                    .lineLimit(2)
                
                HStack {
                    Text(item.category)
                        .font(.system(size: isCompact ? 12 : 14))
                        .foregroundColor(ColorTheme.accentCyan)
                    
                    Text("•")
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Text(item.duration)
                        .font(.system(size: isCompact ? 12 : 14))
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: isCompact ? 14 : 16))
                .foregroundColor(ColorTheme.textSecondary)
        }
        .padding(isCompact ? 15 : 20)
        .futuristicCard()
    }
}

struct LibraryItem: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let duration: String
    let icon: String
}

#Preview {
    LibraryView()
}