import SwiftUI
import SwiftData

struct BarracksContainer: View {
    var body: some View {
        if UIScreen.isIphoneSEClassic {
            BarracksViewSE()
        } else {
            BarracksView()
        }
    }
}

struct BarracksViewSE: View {
    @Query private var users: [UserModel]
    @Query private var habits: [HabitModel]
    @Environment(\.modelContext) var modelContext

    @State private var showCreate = false
    @State private var habitToDelete: HabitModel? = nil
    @State private var habitToEdit: HabitModel? = nil
    @State private var habitForRoad: HabitModel? = nil

    var user: UserModel? { users.first }

    let positions: [CGPoint] = [
        CGPoint(x: 0.72, y: 0.26),
        CGPoint(x: 0.22, y: 0.50),
        CGPoint(x: 0.72, y: 0.74)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color.clear.bg()

                VStack(spacing: 0) {
                    Text("Legion Headquarters")
                        .font(.custom("Palatino-Bold", size: 20))
                        .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.18))
                        .shadow(color: .black.opacity(0.7), radius: 3, x: 0, y: 2)
                        .padding(.top, 36)
                        .padding(.bottom, 8)

                    HStack(spacing: 6) {
                        resourceBoard(asset: "goldBoard", value: user?.gold ?? 0)
                        resourceBoard(asset: "titleBoard", value: user?.title ?? 0)
                        resourceBoard(asset: "artefactsBoard", value: user?.artefacts ?? 0)
                    }
                    .padding(.horizontal, 10)

                    Spacer()
                }

                ForEach(Array(habits.prefix(3).enumerated()), id: \.element.id) { i, habit in
                    let pos = positions[i]
                    HabitCardBubbleSE(
                        habit: habit,
                        onDelete: { habitToDelete = habit },
                        onMarch: { habitForRoad = habit },
                        onEdit: { habitToEdit = habit }
                    )
                    .position(
                        x: geo.size.width * pos.x,
                        y: geo.size.height * pos.y
                    )
                }

                if habits.count < 3 {
                    Button(action: { showCreate = true }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.65, green: 0.08, blue: 0.08))
                                .frame(width: 46, height: 46)
                                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .position(x: geo.size.width - 36, y: geo.size.height - 140.fitH)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { ensureUser() }
        .sheet(isPresented: $showCreate) { RecruitSoldierView() }
        .sheet(item: $habitToEdit) { h in RecruitSoldierView(habitToEdit: h) }
        .sheet(item: $habitForRoad) { h in HabitRoadView(habit: h) }
        .alert("Are you sure you want to delete this habit?", isPresented: Binding(
            get: { habitToDelete != nil },
            set: { if !$0 { habitToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let h = habitToDelete {
                    modelContext.delete(h)
                    try? modelContext.save()
                    habitToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) { habitToDelete = nil }
        }
    }

    private func resourceBoard(asset: String, value: Int) -> some View {
        ZStack {
            Image(asset)
                .resizable()
                .scaledToFit()
                .frame(height: 34)
            Text("\(value)")
                .font(.custom("Palatino-Bold", size: 12))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity)
    }

    private func ensureUser() {
        guard users.isEmpty else { return }
        let u = UserModel(gold: 0, title: 0, artefacts: 0)
        modelContext.insert(u)
        try? modelContext.save()
    }
}

struct HabitCardBubbleSE: View {
    let habit: HabitModel
    let onDelete: () -> Void
    let onMarch: () -> Void
    let onEdit: () -> Void

    var daysDone: Int { habit.days.values.filter { $0 }.count }
    var progress: Double { Double(daysDone) / Double(habit.duration.rawValue) }

    private let cardW: CGFloat = 130
    private let cardH: CGFloat = 116
    private let innerW: CGFloat = 98

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                Image("hapticBg")
                    .resizable()
                    .frame(width: cardW, height: cardH)

                VStack(spacing: 3) {
                    Text(habit.habitClass.rawValue.capitalized)
                        .font(.custom("Palatino-Bold", size: 12))
                        .foregroundColor(Color(red: 0.10, green: 0.04, blue: 0.01))

                    Text(habit.habitName)
                        .font(.custom("Palatino", size: 9))
                        .foregroundColor(Color(red: 0.18, green: 0.09, blue: 0.02))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: innerW)

                    Text("Day \(daysDone) / \(habit.duration.rawValue)")
                        .font(.custom("Palatino-Bold", size: 10))
                        .foregroundColor(Color(red: 0.70, green: 0.10, blue: 0.08))

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.60, green: 0.55, blue: 0.45).opacity(0.5))
                            .frame(width: innerW, height: 5)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.80, green: 0.60, blue: 0.10))
                            .frame(width: innerW * CGFloat(min(progress, 1.0)), height: 5)
                    }

                    Button(action: onMarch) {
                        Text("MARCH")
                            .font(.custom("Palatino-Bold", size: 10))
                            .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.40))
                            .frame(width: innerW)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(red: 0.48, green: 0.06, blue: 0.05))
                                    .overlay(RoundedRectangle(cornerRadius: 5)
                                        .strokeBorder(Color(red: 0.70, green: 0.30, blue: 0.12).opacity(0.5), lineWidth: 1))
                            )
                    }
                }
            }
            .frame(width: cardW, height: cardH)

            VStack(spacing: 4) {
                Button(action: onDelete) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.75, green: 0.12, blue: 0.08))
                            .frame(width: 20, height: 20)
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                Button(action: onEdit) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.85, green: 0.55, blue: 0.10))
                            .frame(width: 20, height: 20)
                        Image(systemName: "pencil")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .offset(x: 8, y: 6)
        }
    }
}

struct BarracksView: View {
    @Query private var users: [UserModel]
    @Query private var habits: [HabitModel]
    @Environment(\.modelContext) private var modelContext

    @State private var showCreate = false
    @State private var habitToDelete: HabitModel? = nil
    @State private var habitToEdit: HabitModel? = nil
    @State private var habitForRoad: HabitModel? = nil

    var user: UserModel? { users.first }

    let positions: [CGPoint] = [
        CGPoint(x: 0.72, y: 0.28),
        CGPoint(x: 0.22, y: 0.52),
        CGPoint(x: 0.72, y: 0.76)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color.clear.bg()

                VStack(spacing: 0) {
                    Text("Legion Headquarters")
                        .font(.custom("Palatino-Bold", size: 26))
                        .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.18))
                        .shadow(color: .black.opacity(0.7), radius: 3, x: 0, y: 2)
                        .padding(.top, 56)
                        .padding(.bottom, 12)

                    HStack(spacing: 12) {
                        resourceBoard(asset: "goldBoard", value: user?.gold ?? 0)
                        resourceBoard(asset: "titleBoard", value: user?.title ?? 0)
                        resourceBoard(asset: "artefactsBoard", value: user?.artefacts ?? 0)
                    }
                    .padding(.horizontal, 16)

                    Spacer()
                }

                ForEach(Array(habits.prefix(3).enumerated()), id: \.element.id) { i, habit in
                    let pos = positions[i]
                    HabitCardBubble(
                        habit: habit,
                        onDelete: { habitToDelete = habit },
                        onMarch: { habitForRoad = habit },
                        onEdit: { habitToEdit = habit }
                    )
                    .position(
                        x: geo.size.width * pos.x,
                        y: geo.size.height * pos.y
                    )
                }

                if habits.count < 3 {
                    Button(action: { showCreate = true }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.65, green: 0.08, blue: 0.08))
                                .frame(width: 56, height: 56)
                                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .position(x: geo.size.width - 44, y: geo.size.height - 120.fitH)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { ensureUser() }
        .sheet(isPresented: $showCreate) { RecruitSoldierView() }
        .sheet(item: $habitToEdit) { h in RecruitSoldierView(habitToEdit: h) }
        .sheet(item: $habitForRoad) { h in HabitRoadView(habit: h) }
        .alert("Are you sure you want to delete this habit?", isPresented: Binding(
            get: { habitToDelete != nil },
            set: { if !$0 { habitToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let h = habitToDelete {
                    modelContext.delete(h)
                    try? modelContext.save()
                    habitToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) { habitToDelete = nil }
        }
    }

    private func resourceBoard(asset: String, value: Int) -> some View {
        ZStack {
            Image(asset)
                .resizable()
                .scaledToFit()
                .frame(height: 44)
            Text("\(value)")
                .font(.custom("Palatino-Bold", size: 16))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                .padding(.leading, 28)
        }
        .frame(maxWidth: .infinity)
    }

    private func ensureUser() {
        guard users.isEmpty else { return }
        let u = UserModel(gold: 0, title: 0, artefacts: 0)
        modelContext.insert(u)
        try? modelContext.save()
    }
}

struct HabitCardBubble: View {
    let habit: HabitModel
    let onDelete: () -> Void
    let onMarch: () -> Void
    let onEdit: () -> Void

    var daysDone: Int { habit.days.values.filter { $0 }.count }

    var progress: Double {
        Double(daysDone) / Double(habit.duration.rawValue)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                Image("hapticBg")
                    .resizable()
                    .frame(width: 170, height: 150)

                VStack(spacing: 5) {
                    Text(habit.habitClass.rawValue.capitalized)
                        .font(.custom("Palatino-Bold", size: 15))
                        .foregroundColor(Color(red: 0.10, green: 0.04, blue: 0.01))

                    Text(habit.habitName)
                        .font(.custom("Palatino", size: 11))
                        .foregroundColor(Color(red: 0.18, green: 0.09, blue: 0.02))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: 130)

                    Text("Day \(daysDone) / \(habit.duration.rawValue)")
                        .font(.custom("Palatino-Bold", size: 12))
                        .foregroundColor(Color(red: 0.70, green: 0.10, blue: 0.08))

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.60, green: 0.55, blue: 0.45).opacity(0.5))
                            .frame(width: 130, height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.80, green: 0.60, blue: 0.10))
                            .frame(width: 130 * CGFloat(min(progress, 1.0)), height: 6)
                    }

                    Button(action: onMarch) {
                        Text("MARCH")
                            .font(.custom("Palatino-Bold", size: 12))
                            .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.40))
                            .frame(width: 130)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(red: 0.48, green: 0.06, blue: 0.05))
                                    .overlay(RoundedRectangle(cornerRadius: 6)
                                        .strokeBorder(Color(red: 0.70, green: 0.30, blue: 0.12).opacity(0.5), lineWidth: 1))
                            )
                    }
                }
            }
            .frame(width: 170, height: 150)

            VStack(spacing: 5) {
                Button(action: onDelete) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(red: 0.75, green: 0.12, blue: 0.08))
                            .frame(width: 26, height: 26)
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                Button(action: onEdit) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(red: 0.85, green: 0.55, blue: 0.10))
                            .frame(width: 26, height: 26)
                        Image(systemName: "pencil")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .offset(x: 10, y: 8)
        }
    }
}
