import Foundation
import SwiftData

@Model
final class MeditationSession {
    var id: UUID = UUID()
    var duration: Int = 0 // in minutes
    var timestamp: Date = Date()
    var completed: Bool = false
    
    init(duration: Int, timestamp: Date = Date(), completed: Bool = false) {
        self.id = UUID()
        self.duration = duration
        self.timestamp = timestamp
        self.completed = completed
    }
}