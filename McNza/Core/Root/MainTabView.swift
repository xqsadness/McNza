import SwiftUI

struct MainTabView: View {
    
    @StateObject private var appSettings = AppSettings.shared
    
    var body: some View {
        TabView(selection: $appSettings.selectedTab) {
            DiscoveryTabView()
                .tag(Tab.musicFeed)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            
            Text("Discovery")
                .tag(Tab.discovery)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            
            Text("Livestream Content")
                .tag(Tab.livestream)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            
            Text("Me Content")
                .tag(Tab.me)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .overlay(
            BottomTabBarView(),
            alignment: .bottom
        )
        .ignoresSafeArea()
        
    }
}

struct BottomTabBarView: View {
    
    @StateObject private var appSettings = AppSettings.shared

    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                if tab == .musicFeed {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                        .contentShape(.rect)
                        .onTapGesture {
                            appSettings.selectedTab = .musicFeed
                        }
                } else {
                    VStack {
                        Image(systemName: tab == .livestream ? "dot.radiowaves.left.and.right" : "person.crop.circle")
                            .foregroundColor(tab == appSettings.selectedTab ? .white : .white.opacity(0.5))
                        Text(tab.rawValue)
                            .font(.caption2)
                            .foregroundColor(tab == appSettings.selectedTab ? .white : .white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        appSettings.selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
}

#Preview {
    MainTabView()
}
