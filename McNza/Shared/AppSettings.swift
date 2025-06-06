//
//  AppSettings.swift
//  McNza
//
//  Created by xqsadness on 5/6/25.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case musicFeed = ""
    case discovery = "Discovery"
    case playlist = "Playlist"
    case me = "Me"
        
    var iconName: String {
        switch self {
        case .musicFeed:
            return "pause.circle.fill"
        case .discovery:
            return "globe"
        case .playlist:
            return "music.note.list"
        case .me:
            return "person.crop.circle"
        }
    }
}

class AppSettings: ObservableObject{
    
    static let shared = AppSettings()
    
    var appName: String {
        if let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return displayName
        } else {
            return "App Name"
        }
    }
    let deviceName = UIDevice.current.name
    
    //Published props
    @Published var selectedTab: Tab = .musicFeed
    @Published var isBlur = false
    
}
