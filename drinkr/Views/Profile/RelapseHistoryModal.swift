import SwiftUI

struct RelapseHistoryModal: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var dataService: DataService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedTimeRange = "All Time"
    
    let timeRanges = ["All Time", "This Year", "This Month", "This Week"]
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    summaryCard
                        .padding(.horizontal)
                    
                    timeRangePicker
                        .padding(.horizontal)
                    
                    relapsesList
                        .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Relapse History")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: 
                Button("Done") {
                    isPresented = false
                }
                .foregroundColor(ColorTheme.accentCyan)
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var summaryCard: some View {
        VStack(spacing: 15) {
            Text("Recovery Overview")
                .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
            
            let stats = getRelapseAnalysis()
            
            HStack(spacing: 20) {
                statColumn(title: "Total", value: "\(stats.total)", color: ColorTheme.warningOrange)
                statColumn(title: "This Month", value: "\(stats.thisMonth)", color: ColorTheme.accentPurple)
                statColumn(title: "Average/Month", value: String(format: "%.1f", stats.averagePerMonth), color: ColorTheme.accentCyan)
            }
            
            if stats.total > 0 {
                VStack(spacing: 8) {
                    Text("Most Common Triggers")
                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    HStack(spacing: 8) {
                        ForEach(stats.topTriggers, id: \.self) { trigger in
                            Text(trigger)
                                .font(.system(size: isCompact ? 12 : 14))
                                .foregroundColor(ColorTheme.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(ColorTheme.accentPurple.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    func statColumn(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: isCompact ? 24 : 28, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: isCompact ? 12 : 14))
                .foregroundColor(ColorTheme.textSecondary)
        }
    }
    
    var timeRangePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(timeRanges, id: \.self) { range in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedTimeRange = range
                        }
                    }) {
                        Text(range)
                            .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                            .foregroundColor(selectedTimeRange == range ? .black : ColorTheme.textPrimary)
                            .padding(.horizontal, isCompact ? 16 : 20)
                            .padding(.vertical, isCompact ? 8 : 10)
                            .background(
                                selectedTimeRange == range ?
                                AnyView(ColorTheme.accentCyan) :
                                AnyView(ColorTheme.cardBackground)
                            )
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedTimeRange == range ? Color.clear : ColorTheme.accentCyan.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
    
    var relapsesList: some View {
        let filteredRelapses = getFilteredRelapses()
        
        return VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Relapse Events")
                    .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Spacer()
                
                Text("\(filteredRelapses.count) events")
                    .font(.system(size: isCompact ? 14 : 16))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            
            if filteredRelapses.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: isCompact ? 40 : 50))
                        .foregroundColor(ColorTheme.successGreen)
                    
                    Text("No relapses in this period!")
                        .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                        .foregroundColor(ColorTheme.successGreen)
                    
                    Text("Keep up the great work!")
                        .font(.system(size: isCompact ? 14 : 16))
                        .foregroundColor(ColorTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredRelapses.sorted { $0.date > $1.date }, id: \.id) { relapse in
                            relapseCard(relapse)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .padding(isCompact ? 20 : 25)
        .futuristicCard()
    }
    
    func relapseCard(_ relapse: Relapse) -> some View {
        HStack(spacing: 15) {
            VStack(spacing: 4) {
                Text(formatDate(relapse.date))
                    .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                    .foregroundColor(ColorTheme.warningOrange)
                
                Text(formatTime(relapse.date))
                    .font(.system(size: isCompact ? 10 : 12))
                    .foregroundColor(ColorTheme.textSecondary)
            }
            .frame(width: isCompact ? 80 : 90)
            
            VStack(alignment: .leading, spacing: 6) {
                if let trigger = relapse.trigger, !trigger.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(ColorTheme.warningOrange)
                        
                        Text("Trigger: \(trigger)")
                            .font(.system(size: isCompact ? 12 : 14, weight: .medium))
                            .foregroundColor(ColorTheme.textPrimary)
                    }
                }
                
                if let notes = relapse.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: isCompact ? 11 : 13))
                        .foregroundColor(ColorTheme.textSecondary)
                        .lineLimit(3)
                } else {
                    Text("No additional notes")
                        .font(.system(size: isCompact ? 11 : 13))
                        .foregroundColor(ColorTheme.textSecondary.opacity(0.7))
                        .italic()
                }
            }
            
            Spacer()
        }
        .padding(isCompact ? 12 : 15)
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ColorTheme.warningOrange.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Helper Functions
    
    func getRelapseAnalysis() -> (total: Int, thisMonth: Int, averagePerMonth: Double, topTriggers: [String]) {
        guard let sobrietyData = dataService.sobrietyData else {
            return (0, 0, 0.0, [])
        }
        
        let total = sobrietyData.relapses.count
        
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        let thisMonth = sobrietyData.relapses.filter { relapse in
            relapse.date >= startOfMonth
        }.count
        
        let monthsSinceQuit = max(1, calendar.dateComponents([.month], from: sobrietyData.quitDate, to: now).month ?? 1)
        let averagePerMonth = Double(total) / Double(monthsSinceQuit)
        
        // Get top triggers
        let triggers = sobrietyData.relapses.compactMap { $0.trigger }.filter { !$0.isEmpty }
        let triggerCounts = Dictionary(triggers.map { ($0, 1) }, uniquingKeysWith: +)
        let topTriggers = triggerCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
        
        return (total, thisMonth, averagePerMonth, Array(topTriggers))
    }
    
    func getFilteredRelapses() -> [Relapse] {
        guard let sobrietyData = dataService.sobrietyData else { return [] }
        
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date
        
        switch selectedTimeRange {
        case "This Week":
            startDate = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        case "This Month":
            startDate = calendar.dateInterval(of: .month, for: now)?.start ?? now
        case "This Year":
            startDate = calendar.dateInterval(of: .year, for: now)?.start ?? now
        default: // "All Time"
            return sobrietyData.relapses
        }
        
        return sobrietyData.relapses.filter { $0.date >= startDate }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    RelapseHistoryModal(isPresented: .constant(true))
        .environmentObject(DataService())
}