import SwiftUI
import SwiftData

struct RecruitSoldierView: View {
    var habitToEdit: HabitModel? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var missionName = ""
    @State private var selectedClass: HabitClass = .tiro
    @State private var selectedDuration: HabitDuration = .`30`
    @State private var selectedReward: Reward? = nil
    @State private var showRewardPicker = false

    var isEditing: Bool { habitToEdit != nil }
    var canCreate: Bool { !missionName.trimmingCharacters(in: .whitespaces).isEmpty && selectedReward != nil }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        fieldSection("Mission Name") {
                            HStack {
                                TextField("e.g. Read 30 minutes", text: $missionName)
                                    .font(.custom("Palatino", size: 15))
                                    .foregroundColor(.white)
                                if !missionName.isEmpty {
                                    Button(action: { missionName = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white.opacity(0.4))
                                    }
                                }
                            }
                            .padding(.horizontal, 14).padding(.vertical, 14)
                            .background(inputBg)
                        }

                        fieldSection("Class (Difficulty)") {
                            HStack(spacing: 8) {
                                classCard(.tiro, icon: "shield", sub: "Easy")
                                classCard(.miles, icon: "hammer", sub: "Medium")
                                classCard(.centurion, icon: "crown", sub: "Hard")
                            }
                        }

                        fieldSection("Campaign Duration") {
                            HStack(spacing: 8) {
                                durationCard(.`7`, sub: "Recon")
                                durationCard(.`30`, sub: "Standard")
                                durationCard(.`100`, sub: "Great")
                            }
                        }

                        fieldSection("Triumph Reward") {
                            Button(action: { showRewardPicker.toggle() }) {
                                HStack {
                                    Text(selectedReward?.displayName ?? "Choose")
                                        .font(.custom("Palatino", size: 15))
                                        .foregroundColor(selectedReward != nil ? .white : .white.opacity(0.4))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(.horizontal, 14).padding(.vertical, 14)
                                .background(inputBg)
                            }

                            if showRewardPicker {
                                VStack(spacing: 0) {
                                    ForEach(Reward.allCases, id: \.self) { r in
                                        Button(action: { selectedReward = r; showRewardPicker = false }) {
                                            HStack {
                                                Text(r.displayName)
                                                    .font(.custom("Palatino", size: 14))
                                                    .foregroundColor(.white)
                                                Spacer()
                                                if selectedReward == r {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.18))
                                                }
                                            }
                                            .padding(.horizontal, 14).padding(.vertical, 11)
                                        }
                                        if r != Reward.allCases.last {
                                            Divider().background(Color.white.opacity(0.1))
                                        }
                                    }
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 0.14, green: 0.10, blue: 0.07))
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color(red: 0.55, green: 0.35, blue: 0.15).opacity(0.4), lineWidth: 1))
                                )
                            }
                        }

                        Spacer(minLength: 100.fitH)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }

                Button(action: create) {
                    Text(isEditing ? "Save Changes" : "Draft to Ranks")
                        .font(.custom("Palatino-Bold", size: 17))
                        .foregroundColor(canCreate
                            ? Color(red: 1.0, green: 0.82, blue: 0.45)
                            : Color(red: 0.60, green: 0.45, blue: 0.25))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(canCreate
                                    ? Color(red: 0.50, green: 0.08, blue: 0.06)
                                    : Color(red: 0.22, green: 0.14, blue: 0.10))
                                .overlay(RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(canCreate
                                        ? Color(red: 0.70, green: 0.30, blue: 0.10).opacity(0.6)
                                        : Color.clear, lineWidth: 1))
                        )
                }
                .disabled(!canCreate)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color(red: 0.10, green: 0.07, blue: 0.05).ignoresSafeArea())
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.18))
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Recruit Soldier")
                            .font(.custom("Palatino-Bold", size: 18))
                            .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.18))
                        Text("Form a new habit legion")
                            .font(.custom("Palatino-Italic", size: 12))
                            .foregroundColor(Color(red: 0.75, green: 0.60, blue: 0.40))
                    }
                }
            }
            .toolbarBackground(Color(red: 0.10, green: 0.07, blue: 0.05), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                guard let h = habitToEdit else { return }
                missionName = h.habitName
                selectedClass = h.habitClass
                selectedDuration = h.duration
                selectedReward = h.reward
            }
        }
    }

    private func fieldSection<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Text(title.uppercased())
                    .font(.custom("Palatino-Bold", size: 13))
                    .foregroundColor(.white)
                Text("*")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.80, green: 0.18, blue: 0.12))
            }
            content()
        }
    }

    private func classCard(_ cls: HabitClass, icon: String, sub: String) -> some View {
        let isSelected = selectedClass == cls
        return Button(action: { selectedClass = cls }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.72, blue: 0.18) : .white.opacity(0.6))
                Text(cls.rawValue.capitalized)
                    .font(.custom("Palatino-Bold", size: 13))
                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.72, blue: 0.18) : .white.opacity(0.7))
                Text(sub.uppercased())
                    .font(.custom("Palatino", size: 10))
                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.72, blue: 0.18).opacity(0.7) : .white.opacity(0.35))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected
                        ? Color(red: 0.28, green: 0.16, blue: 0.06)
                        : Color(red: 0.16, green: 0.11, blue: 0.07))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(isSelected
                            ? Color(red: 0.70, green: 0.45, blue: 0.15).opacity(0.7)
                            : Color.white.opacity(0.08), lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }

    private func durationCard(_ dur: HabitDuration, sub: String) -> some View {
        let isSelected = selectedDuration == dur
        return Button(action: { selectedDuration = dur }) {
            VStack(spacing: 4) {
                Text("\(dur.rawValue)")
                    .font(.custom("Palatino-Bold", size: 22))
                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.72, blue: 0.18) : .white.opacity(0.7))
                Text(sub.uppercased())
                    .font(.custom("Palatino", size: 10))
                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.72, blue: 0.18).opacity(0.7) : .white.opacity(0.35))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected
                        ? Color(red: 0.28, green: 0.16, blue: 0.06)
                        : Color(red: 0.16, green: 0.11, blue: 0.07))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(isSelected
                            ? Color(red: 0.70, green: 0.45, blue: 0.15).opacity(0.7)
                            : Color.white.opacity(0.08), lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }

    private var inputBg: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(red: 0.14, green: 0.10, blue: 0.07))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color(red: 0.55, green: 0.35, blue: 0.15).opacity(0.4), lineWidth: 1))
    }

    private func create() {
        guard let reward = selectedReward else { return }
        if let h = habitToEdit {
            h.habitName = missionName
            h.habitClass = selectedClass
            h.duration = selectedDuration
            h.reward = reward
        } else {
            let habit = HabitModel(
                habitName: missionName,
                habitClass: selectedClass,
                duration: selectedDuration,
                reward: reward,
                days: [:]
            )
            modelContext.insert(habit)
        }
        try? modelContext.save()
        dismiss()
    }
}

extension Reward {
    var displayName: String {
        switch self {
        case .gold:     return "Gold"
        case .title:    return "Title"
        case .artefact: return "Artifact"
        }
    }
}
