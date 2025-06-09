import SwiftUI
import _SwiftData_SwiftUI

enum FilterType: String, CaseIterable {
    case all = "All"
    case liked = "Liked"
    case recent = "Recent"
}

struct MainTabView: View {
    
    @StateObject private var appSettings = AppSettings.shared
    @State var mainReelPlayerVm = MainReelPlayerViewModel()

    init(){
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        TabView(selection: $appSettings.selectedTab) {
            MainReelPlayerView()
                .environment(mainReelPlayerVm)
                .tag(Tab.musicFeed)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            
            Text("Discovery")
                .tag(Tab.discovery)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            
            PlaylistView()
                .tag(Tab.playlist)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            
            Text("Me Content")
                .tag(Tab.me)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
        }
        .overlay(
            BottomTabBarView(),
            alignment: .bottom
        )
        .overlay(alignment: .topTrailing){
            HStack(spacing: 15) {
                ForEach(FilterType.allCases, id: \.self) { filter in
                    Text(filter.rawValue)
                        .font(.system(size: 20)).bold()
                        .foregroundStyle(mainReelPlayerVm.selectedFilter == filter ? .primary : Color.gray)
                        .contentShape(.rect)
                        .onTapGesture {
                            mainReelPlayerVm.selectedFilter = filter
                        }
                }
                
                Image(systemName: "magnifyingglass")
                    .imageScale(.large)
                    .hSpacing(.trailing)
            }
            .safeAreaPadding(.top, 55)
            .padding(.horizontal)
            .opacity(AppSettings.shared.selectedTab == .musicFeed ? 1 : 0.0001)
        }
        .ignoresSafeArea()
    }
}

struct BottomTabBarView: View {
    
    @StateObject private var appSettings = AppSettings.shared
    @State var player = PlayerService.shared
    @Query(sort: \Song.dateAdd, order: .reverse) var songs: [Song]
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                if tab == .musicFeed {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .contentShape(.rect)
                        .onTapGesture {
                            if appSettings.selectedTab != .musicFeed {
                                appSettings.selectedTab = .musicFeed
                            } else {
                                let index = player.currentIndex
                                if index >= 0 && index < songs.count {
                                    player.play(song: songs[index], in: songs)
                                } else if let firstSong = songs.first {
                                    player.play(song: firstSong, in: songs)
                                    
                                }
                            }
                        }
                } else {
                    VStack {
                        Image(systemName: tab.iconName)
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
        .safeAreaPadding(.bottom, 30)
        .background{appSettings.selectedTab == .musicFeed ? .clear : Color(.black)}
    }
}

#Preview {
    MainTabView()
}
