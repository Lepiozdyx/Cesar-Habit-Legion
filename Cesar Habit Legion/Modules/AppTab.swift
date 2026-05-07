import SwiftUI

enum AppTab: CaseIterable {
    case barracks, triumph, senate

    var title: String {
        switch self {
        case .barracks: return "Barracks"
        case .triumph:  return "Triumph"
        case .senate:   return "Senate"
        }
    }

    var icon: String {
        switch self {
        case .barracks: return "tent.fill"
        case .triumph:  return "rosette"
        case .senate:   return "scroll.fill"
        }
    }
}

struct TabBarView: View {
    @State private var selected: AppTab = .barracks

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selected {
                case .barracks: BarracksContainer()
                case .triumph:  TriumphView()
                case .senate:   SenateView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selected: $selected)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct CustomTabBar: View {
    @Binding var selected: AppTab

    private let activeColor  = Color(red: 1.00, green: 0.65, blue: 0.10)
    private let inactiveColor = Color(red: 0.60, green: 0.52, blue: 0.46)
    private let bg = Color(red: 0.10, green: 0.09, blue: 0.08)

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabItem(tab)
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 28)
        .background(
            bg
        )
    }

    private func tabItem(_ tab: AppTab) -> some View {
        let isSelected = selected == tab
        let color = isSelected ? activeColor : inactiveColor

        return Button(action: { selected = tab }) {
            VStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.system(size: 26, weight: .regular))
                    .foregroundColor(color)
                Text(tab.title)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
