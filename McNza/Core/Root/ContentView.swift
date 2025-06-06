//
//  ContentView.swift
//  McNza
//
//  Created by xqsadness on 5/6/25.
//

import SwiftUI

struct ContentView: View {
    
    @Bindable private var coordinator = Coordinator.shared
    @StateObject private var app = AppSettings.shared
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            MainTabView()
                .navigationDestination(for: UUID.self) { id in
                    coordinator.viewForID(id)
                }
                .sheet(item: $coordinator.sheetID) { id in
                    coordinator.viewForID(id)
                }
                .fullScreenCover(item: $coordinator.fullScreenCoverID) { id in
                    coordinator.viewForID(id)
                }
        }
        .blur(radius: app.isBlur ? 6.6: 0)
        .opacity(app.isBlur ? 0.5 : 1)
        .environment(coordinator)
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ContentView()
}
