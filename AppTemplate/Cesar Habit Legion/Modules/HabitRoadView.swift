import SwiftUI
import SwiftData

struct HabitRoadView: View {
    @Bindable var habit: HabitModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var userNodeIndex: Int = 0
    @State private var animating = false

    var daysDone: Int { habit.days.values.filter { $0 }.count }

    var alreadyMarkedToday: Bool {
        let cal = Calendar.current
        return habit.days.keys.contains { cal.isDateInToday($0) }
    }

    var visibleDays: [Int] {
        let start = max(daysDone - 1, 1)
        return (start..<(start + 5)).map { $0 }
    }

    let nodePositions: [(x: CGFloat, y: CGFloat)] = [
        (0.38, 0.12),
        (0.60, 0.25),
        (0.38, 0.40),
        (0.28, 0.56),
        (0.55, 0.72)
    ]

    func isDone(_ day: Int) -> Bool {
        habit.days.values.filter { $0 }.count >= day
    }

    func isCurrentDay(_ day: Int) -> Bool {
        day == daysDone + 1
    }

    var currentIndexInVisible: Int {
        visibleDays.firstIndex(where: { isCurrentDay($0) }) ?? 0
    }

    func march() {
        guard !alreadyMarkedToday else { return }
        let next = daysDone + 1
        guard next <= habit.duration.rawValue else { return }

        let today = Calendar.current.startOfDay(for: Date())
        habit.days[today] = true
        try? modelContext.save()

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            userNodeIndex = currentIndexInVisible
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.clear.roadBg()

                VStack(spacing: 4) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                        }
                        Spacer()
                    }

                    Text(habit.habitName.uppercased())
                        .font(.custom("Palatino-Bold", size: 22))
                        .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.18))
                        .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Text("\(habit.habitClass.rawValue.capitalized) • Day \(daysDone) of \(habit.duration.rawValue)")
                        .font(.custom("Palatino", size: 14))
                        .foregroundColor(.white.opacity(0.85))

                    Spacer()
                }
                .padding(.top, 48)

                ForEach(Array(visibleDays.enumerated()), id: \.element) { i, day in
                    let nx = geo.size.width * nodePositions[i].x
                    let ny = geo.size.height * nodePositions[i].y + 100

                    ZStack {
                        Circle()
                            .fill(nodeColor(day))
                            .frame(width: 52, height: 52)
                            .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                        Text("\(day)")
                            .font(.custom("Palatino-Bold", size: 16))
                            .foregroundColor(.white)
                    }
                    .position(x: nx, y: ny)
                }

                let userIdx = alreadyMarkedToday ? currentIndexInVisible : max(currentIndexInVisible - 1, 0)
                let ux = geo.size.width * nodePositions[userIdx].x
                let uy = geo.size.height * nodePositions[userIdx].y + 100

                Image("userAsset")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 90)
                    .position(x: ux, y: uy - 68)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: userIdx)

                VStack {
                    Spacer()
                    Button(action: march) {
                        Text("MARCH")
                            .font(.custom("Palatino-Bold", size: 18))
                            .foregroundColor(alreadyMarkedToday
                                ? Color(red: 0.60, green: 0.45, blue: 0.25)
                                : Color(red: 1.0, green: 0.82, blue: 0.40))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(alreadyMarkedToday
                                        ? Color(red: 0.22, green: 0.14, blue: 0.10)
                                        : Color(red: 0.48, green: 0.06, blue: 0.05))
                                    .overlay(RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color(red: 0.70, green: 0.30, blue: 0.12).opacity(0.5), lineWidth: 1))
                            )
                    }
                    .disabled(alreadyMarkedToday)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40.fitH)
                }
            }
        }
        .ignoresSafeArea()
    }

    private func nodeColor(_ day: Int) -> Color {
        if isDone(day) {
            return Color(red: 0.10, green: 0.72, blue: 0.50)
        } else if isCurrentDay(day) {
            return Color(red: 0.90, green: 0.60, blue: 0.10)
        } else {
            return Color(red: 0.52, green: 0.08, blue: 0.10)
        }
    }
}
