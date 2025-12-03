import Foundation
import SwiftData

@Model
class FocusTask: Identifiable {
    var id: UUID
    var title: String
    var subtitle: String
    var icon: String
    var isCompleted: Bool
    var date: Date
    
    init(title: String, subtitle: String, icon: String, isCompleted: Bool = false, date: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isCompleted = isCompleted
        self.date = date
    }
}
