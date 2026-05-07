import SwiftUI
import SwiftData

struct Achievement: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let check: ([HabitModel]) -> Bool
}

struct TriumphView: View {
    @Query private var habits: [HabitModel]

    let achievements: [Achievement] = [
        Achievement(
            icon: "laurel.leading",
            title: "Grass Crown",
            description: "Complete your first habit for 3 consecutive days",
            check: { habits in
                habits.contains { h in
                    let sorted = h.days.filter { $0.value }.keys.sorted()
                    guard sorted.count >= 3 else { return false }
                    for i in 0..<(sorted.count - 2) {
                        let a = sorted[i], b = sorted[i+1], c = sorted[i+2]
                        let cal = Calendar.current
                        if cal.isDate(b, inSameDayAs: cal.date(byAdding: .day, value: 1, to: a)!) &&
                           cal.isDate(c, inSameDayAs: cal.date(byAdding: .day, value: 2, to: a)!) {
                            return true
                        }
                    }
                    return false
                }
            }
        ),
        Achievement(
            icon: "circle.dotted",
            title: "Civic Crown",
            description: "Maintain a 7-day streak (no missed days)",
            check: { habits in
                habits.contains { h in
                    let sorted = h.days.filter { $0.value }.keys.sorted()
                    guard sorted.count >= 7 else { return false }
                    let cal = Calendar.current
                    for i in 0..<(sorted.count - 6) {
                        var streak = true
                        for j in 1..<7 {
                            guard let next = cal.date(byAdding: .day, value: j, to: sorted[i]) else { streak = false; break }
                            if !sorted.contains(where: { cal.isDate($0, inSameDayAs: next) }) { streak = false; break }
                        }
                        if streak { return true }
                    }
                    return false
                }
            }
        ),
        Achievement(
            icon: "building.columns",
            title: "Wall and Ditch",
            description: "Complete your first 30-day campaign",
            check: { habits in
                habits.contains { $0.duration == .`30` && $0.days.values.filter { $0 }.count >= 30 }
            }
        ),
        Achievement(
            icon: "crown",
            title: "Ovation",
            description: "Complete 5 habits simultaneously for one week",
            check: { habits in habits.count >= 5 }
        ),
        Achievement(
            icon: "star.fill",
            title: "Emperor's Triumph",
            description: "Complete 3 campaigns in a row without missing a day",
            check: { habits in
                habits.filter { $0.days.values.filter { $0 }.count >= $0.duration.rawValue }.count >= 3
            }
        ),
        Achievement(
            icon: "scroll",
            title: "Law of the Twelve Tables",
            description: "Create 12 different habits",
            check: { habits in habits.count >= 12 }
        ),
        Achievement(
            icon: "pawprint.fill",
            title: "She-Wolf of Romulus",
            description: "Recover a \"deserter\" habit after missing more than 3 days",
            check: { habits in
                habits.contains { h in
                    let sorted = h.days.filter { $0.value }.keys.sorted()
                    guard sorted.count >= 2 else { return false }
                    let cal = Calendar.current
                    for i in 0..<(sorted.count - 1) {
                        let diff = cal.dateComponents([.day], from: sorted[i], to: sorted[i+1]).day ?? 0
                        if diff > 3 { return true }
                    }
                    return false
                }
            }
        ),
        Achievement(
            icon: "building.columns.fill",
            title: "Pantheon",
            description: "Unlock all legionary types (Tiro, Miles, Centurion)",
            check: { habits in
                let classes = Set(habits.map { $0.habitClass })
                return classes.contains(.tiro) && classes.contains(.miles) && classes.contains(.centurion)
            }
        ),
        Achievement(
            icon: "bag.fill",
            title: "Imperial Treasury",
            description: "Accumulate 10,000 experience points (Denarii)",
            check: { habits in
                let total = habits.map { $0.days.values.filter { $0 }.count }.reduce(0, +)
                return total >= 10000
            }
        ),
        Achievement(
            icon: "shield.fill",
            title: "Gladius Hispaniensis",
            description: "Reach 100 total days of habit activity",
            check: { habits in
                let total = habits.map { $0.days.values.filter { $0 }.count }.reduce(0, +)
                return total >= 100
            }
        )
    ]

    var body: some View {
        ZStack {
            Color(red: 0.10, green: 0.07, blue: 0.04).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Text("Hall of Triumph")
                        .font(.custom("Palatino-Bold", size: 26))
                        .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.18))
                        .padding(.top, 56)
                        .padding(.bottom, 4)

                    Text("Glory to the victorious.")
                        .font(.custom("Palatino-Italic", size: 14))
                        .foregroundColor(Color(red: 0.75, green: 0.60, blue: 0.40))
                        .padding(.bottom, 24)

                    VStack(spacing: 10) {
                        ForEach(achievements) { ach in
                            let unlocked = ach.check(habits)
                            AchievementRow(achievement: ach, unlocked: unlocked)
                        }
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 100.fitH)
                }
            }
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    let unlocked: Bool

    private let df: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "d.M.yyyy"; return f
    }()

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(unlocked
                        ? Color(red: 0.22, green: 0.14, blue: 0.06)
                        : Color(red: 0.14, green: 0.11, blue: 0.08))
                    .frame(width: 54, height: 54)
                    .overlay(Circle()
                        .strokeBorder(
                            unlocked
                            ? Color(red: 0.65, green: 0.45, blue: 0.15).opacity(0.7)
                            : Color(red: 0.35, green: 0.28, blue: 0.20).opacity(0.5),
                            lineWidth: 1.5))

                Image(systemName: achievement.icon)
                    .font(.system(size: 22))
                    .foregroundColor(unlocked
                        ? Color(red: 0.90, green: 0.70, blue: 0.30)
                        : Color(red: 0.50, green: 0.42, blue: 0.32))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.custom("Palatino-Bold", size: 15))
                    .foregroundColor(unlocked ? .white : Color(red: 0.65, green: 0.55, blue: 0.42))

                Text(achievement.description)
                    .font(.custom("Palatino", size: 11))
                    .foregroundColor(unlocked
                        ? Color(red: 0.75, green: 0.65, blue: 0.50)
                        : Color(red: 0.50, green: 0.42, blue: 0.32))
                    .fixedSize(horizontal: false, vertical: true)

                if unlocked {
                    Text("Unlocked: \(df.string(from: Date()))")
                        .font(.custom("Palatino", size: 10))
                        .foregroundColor(Color(red: 0.70, green: 0.45, blue: 0.15))
                }
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(unlocked
                    ? Color(red: 0.18, green: 0.12, blue: 0.06)
                    : Color(red: 0.13, green: 0.10, blue: 0.07))
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        unlocked
                        ? Color(red: 0.55, green: 0.35, blue: 0.12).opacity(0.5)
                        : Color(red: 0.30, green: 0.22, blue: 0.14).opacity(0.4),
                        lineWidth: 1))
        )
    }
}
