import Foundation
import SwiftData

@Model
final class CheckIn {
    var id: UUID = UUID()
    var mood: Int = 3
    var notes: String = ""
    var timestamp: Date = Date()
    
    init(mood: Int, notes: String = "", timestamp: Date = Date()) {
        self.id = UUID()
        self.mood = mood
        self.notes = notes
        self.timestamp = timestamp
    }
}