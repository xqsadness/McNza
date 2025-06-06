//
//  McNzaApp.swift
//  McNza
//
//  Created by xqsadness on 5/6/25.
//

import SwiftUI
import SwiftData

@main
struct McNzaApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegateSwiftUI
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Song.self,
            PlayList.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RootView{
                ContentView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
