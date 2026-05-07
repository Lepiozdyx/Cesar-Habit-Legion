import SwiftUI
import SwiftData

struct Cesar_Habit_LegionApp: View {
    var body: some View {
        TabBarView()
            .preferredColorScheme(.dark)
            .modelContainer(for: [
                UserModel.self,
                HabitModel.self,
            ])
    }
}
