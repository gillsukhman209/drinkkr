import Foundation
import SwiftData

@Model
final class User {
    var id: UUID
    var name: String
    var email: String?
    var avatarImageName: String?
    var joinedDate: Date
    var notificationsEnabled: Bool
    var notificationTime: Date
    var darkModeEnabled: Bool
    
    init(
        name: String = "Anonymous",
        email: String? = nil,
        avatarImageName: String? = nil,
        joinedDate: Date = Date(),
        notificationsEnabled: Bool = true,
        notificationTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
        darkModeEnabled: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.avatarImageName = avatarImageName
        self.joinedDate = joinedDate
        self.notificationsEnabled = notificationsEnabled
        self.notificationTime = notificationTime
        self.darkModeEnabled = darkModeEnabled
    }
}