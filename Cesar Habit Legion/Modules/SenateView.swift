import SwiftUI
import SwiftData

struct SenateView: View {
    @Query private var habits: [HabitModel]

    var totalDays: Int { habits.map { $0.days.values.filter { $0 }.count }.reduce(0, +) }

    var discipline: Int {
        guard !habits.isEmpty else { return 0 }
        let total = habits.map { $0.duration.rawValue }.reduce(0, +)
        guard total > 0 else { return 0 }
        return min(100, totalDays * 100 / total)
    }

    var deserters: Int {
        habits.filter { h in
            let sorted = h.days.filter { $0.value }.keys.sorted()
            guard sorted.count >= 2 else { return false }
            let cal = Calendar.current
            for i in 0..<(sorted.count - 1) {
                let diff = cal.dateComponents([.day], from: sorted[i], to: sorted[i+1]).day ?? 0
                if diff > 3 { return true }
            }
            return false
        }.count
    }

    var territories: Int { habits.map { $0.duration.rawValue }.reduce(0, +) }

    var monthlyActivity: [(label: String, value: Int)] {
        let cal = Calendar.current
        let fmt = DateFormatter(); fmt.dateFormat = "MMM"
        return (-5...0).compactMap { i -> (String, Int)? in
            guard let d = cal.date(byAdding: .month, value: i, to: Date()) else { return nil }
            let comps = cal.dateComponents([.year, .month], from: d)
            let total = habits.flatMap { Array($0.days.keys) }.filter {
                let ec = cal.dateComponents([.year, .month], from: $0)
                return ec.year == comps.year && ec.month == comps.month
            }.count
            return (fmt.string(from: d), total)
        }
    }

    var troopBalance: [(label: String, value: Int, color: Color)] {
        let centurion = habits.filter { $0.habitClass == .centurion }.count
        let tiro      = habits.filter { $0.habitClass == .tiro }.count
        let miles     = habits.filter { $0.habitClass == .miles }.count
        var result: [(String, Int, Color)] = []
        if centurion > 0 { result.append(("Centurion", centurion, Color(red: 0.10, green: 0.75, blue: 0.50))) }
        if tiro > 0      { result.append(("Tiro",      tiro,      Color(red: 0.90, green: 0.65, blue: 0.10))) }
        if miles > 0     { result.append(("Miles",     miles,     Color(red: 0.80, green: 0.15, blue: 0.10))) }
        return result
    }

    var body: some View {
        ZStack {
            Color(red: 0.10, green: 0.07, blue: 0.04).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Senate Reports")
                            .font(.custom("Palatino-Bold", size: 26))
                            .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.18))
                            .padding(.top, 56)
                        Text("State of the Empire.")
                            .font(.custom("Palatino-Italic", size: 14))
                            .foregroundColor(Color(red: 0.75, green: 0.60, blue: 0.40))
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        statCard(icon: "figure.fencing", value: "\(totalDays)", label: "Legion Strength")
                        statCard(icon: "globe",          value: "\(territories)", label: "Territories")
                        statCard(icon: "scope",          value: "\(discipline)%", label: "Discipline")
                        statCard(icon: "person.slash",   value: "\(deserters)",   label: "Deserters")
                    }
                    .padding(.horizontal, 16)

                    VStack(spacing: 14) {
                        Text("Campaign Activity")
                            .font(.custom("Palatino-Bold", size: 20))
                            .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.18))

                        SenateBarChart(data: monthlyActivity)
                            .frame(height: 160)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0.14, green: 0.09, blue: 0.06))
                            .overlay(RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color(red: 0.45, green: 0.28, blue: 0.10).opacity(0.4), lineWidth: 1))
                    )
                    .padding(.horizontal, 16)

                    if !troopBalance.isEmpty {
                        VStack(spacing: 16) {
                            Text("Troop Balance")
                                .font(.custom("Palatino-Bold", size: 20))
                                .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.18))

                            DonutChart(data: troopBalance)
                                .frame(width: 160, height: 160)

                            HStack(spacing: 18) {
                                ForEach(troopBalance, id: \.label) { item in
                                    HStack(spacing: 6) {
                                        Circle().fill(item.color).frame(width: 10, height: 10)
                                        Text(item.label)
                                            .font(.custom("Palatino-Bold", size: 12))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.14, green: 0.09, blue: 0.06))
                                .overlay(RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color(red: 0.45, green: 0.28, blue: 0.10).opacity(0.4), lineWidth: 1))
                        )
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 100.fitH)
                }
            }
        }
    }

    private func statCard(icon: String, value: String, label: String) -> some View {
        ZStack {
            Image("hapticBg")
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .cornerRadius(12)

            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(red: 0.25, green: 0.15, blue: 0.05))
                Text(value)
                    .font(.custom("Palatino-Bold", size: 28))
                    .foregroundColor(Color(red: 0.12, green: 0.07, blue: 0.02))
                Text(label.uppercased())
                    .font(.custom("Palatino", size: 10))
                    .foregroundColor(Color(red: 0.30, green: 0.18, blue: 0.06))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct SenateBarChart: View {
    let data: [(label: String, value: Int)]
    var maxVal: Int { max(data.map(\.value).max() ?? 1, 1) }
    let barColor = Color(red: 0.65, green: 0.12, blue: 0.10)

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height - 20
            let slot = w / CGFloat(data.count)
            let barW = slot * 0.55

            ZStack(alignment: .bottomLeading) {
                ForEach(Array(data.enumerated()), id: \.offset) { i, item in
                    let x = CGFloat(i) * slot + slot / 2 - barW / 2
                    let bh = max(CGFloat(item.value) / CGFloat(maxVal) * h, item.value > 0 ? 4 : 0)

                    VStack(spacing: 0) {
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(
                                colors: [barColor.opacity(0.9), barColor],
                                startPoint: .top, endPoint: .bottom))
                            .frame(width: barW, height: bh)
                        Text(item.label)
                            .font(.custom("Palatino", size: 10))
                            .foregroundColor(.white.opacity(0.55))
                            .frame(height: 18)
                    }
                    .frame(height: h + 18)
                    .offset(x: x)
                }
            }
        }
    }
}

struct DonutChart: View {
    let data: [(label: String, value: Int, color: Color)]
    var total: Double { Double(data.map(\.value).reduce(0, +)) }
    let thickness: CGFloat = 28

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cx = geo.size.width / 2
            let cy = geo.size.height / 2
            let r = size / 2 - thickness / 2
            var start = -Double.pi / 2

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.05), lineWidth: thickness)
                    .frame(width: r * 2, height: r * 2)
                    .position(x: cx, y: cy)

                ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                    let sweep = (Double(item.value) / total) * 2 * Double.pi
                    let sa = start
                    let _ = { start += sweep }()

                    Path { p in
                        p.addArc(center: CGPoint(x: cx, y: cy),
                                 radius: r,
                                 startAngle: .radians(sa),
                                 endAngle: .radians(sa + sweep),
                                 clockwise: false)
                    }
                    .stroke(item.color, style: StrokeStyle(lineWidth: thickness, lineCap: .butt))
                }
            }
        }
    }
}
