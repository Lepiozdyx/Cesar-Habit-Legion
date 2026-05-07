import SwiftData
import Foundation

@Model
class UserModel {
    var id = UUID()
    
    var gold: Int
    var title: Int
    var artefacts: Int
    
    init(id: UUID = UUID(), gold: Int, title: Int, artefacts: Int) {
        self.id = id
        self.gold = gold
        self.title = title
        self.artefacts = artefacts
    }
}

@Model
class HabitModel {
    var id = UUID()
    var dateCreated = Date()
    
    var habitName: String
    var habitClass: HabitClass
    var duration: HabitDuration
    var reward: Reward
    
    var days: [Date: Bool] // за какие дни была отмечена привычка
    
    init(id: UUID = UUID(), dateCreated: Date = Date(), habitName: String, habitClass: HabitClass, duration: HabitDuration, reward: Reward, days: [Date : Bool]) {
        self.id = id
        self.dateCreated = dateCreated
        self.habitName = habitName
        self.habitClass = habitClass
        self.duration = duration
        self.reward = reward
        self.days = days
    }
}

enum HabitClass: String, Codable, CaseIterable {
    case tiro, miles, centurion
}

enum HabitDuration: Int, CaseIterable, Codable {
    case `7` = 7
    case `30` = 30
    case `100` = 100
}

enum Reward: String, Codable, CaseIterable {
    case gold, title, artefact
}
