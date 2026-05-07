import SwiftUI
import SwiftData

@main
struct Cesar_Habit_LegionApp: App {
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [
            UserModel.self,
            HabitModel.self,
        ])
    }
}
