import SwiftUI

//define the different tabs in the bottom navigation bar
enum BottomTabModel: String, Identifiable, CaseIterable, Hashable, Sendable, CustomStringConvertible {
    case home
    case trending
    case add
    case friends
    case profile

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .home: return "house"
        case .trending: return "flame"
        case .add: return "plus.app"
        case .friends: return "person.line.dotted.person"
        case .profile: return "person"
        }
    }

    var description: String {
        switch self {
        case .home: return ""
        case .trending: return ""
        case .add: return ""
        case .friends: return ""
        case .profile: return ""
        }
    }
}

// bar at the bottom of the screen 
struct FloatingBottomNav: View {
    let tabs: [BottomTabModel]
    @Binding var selectedTab: BottomTabModel
    var spacing: CGFloat = 8

    @Namespace private var namespace

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(tabs) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .imageScale(.large)
                        if selectedTab == tab {
                            Text(tab.description)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    .background {
                        if selectedTab == tab {
                            Capsule()
                                .fill(Color.accentColor.opacity(0.15))
                                .matchedGeometryEffect(id: "selectionPill", in: namespace)
                        }
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(selectedTab == tab ? Color.accentColor : .secondary)
            }
        }
        .padding(6)
        .background {
            Capsule()
                .fill(.thinMaterial)
                .shadow(color: .black.opacity(0.9), radius: 8, x: 0, y: 4)
        }
        .animation(.bouncy.speed(1), value: selectedTab)
        .ignoresSafeArea(.keyboard)
    }
}

// main view which shows which tab is active and the right page + bottom bar
struct NavBarView: View {
    @State private var activeTab: BottomTabModel = .home
    
    var body: some View {
        VStack(spacing: 0) {
            //TabView is used to show the different pages of the app
            TabView(selection: $activeTab) {
                MapView()
                    .tag(BottomTabModel.home)
                    .toolbar(.hidden, for: .tabBar)

                TabPlaceholder(title: "Trending")
                //need to replace 
                    .tag(BottomTabModel.trending)
                    .toolbar(.hidden, for: .tabBar)

                TabPlaceholder(title: "Add")
                //need to replace 
                    .tag(BottomTabModel.add)
                    .toolbar(.hidden, for: .tabBar)

                TabPlaceholder(title: "Friends")
                //need to replace 
                    .tag(BottomTabModel.friends)
                    .toolbar(.hidden, for: .tabBar)

                TabPlaceholder(title: "Profile")
                //need to replace   
                    .tag(BottomTabModel.profile)
                    .toolbar(.hidden, for: .tabBar)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            //FloatingBottomNav is used to show the bottom navigation bar
            FloatingBottomNav(tabs: BottomTabModel.allCases, selectedTab: $activeTab)
        }
    }
}

private struct TabPlaceholder: View {
    let title: String

    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavBarView()
}
