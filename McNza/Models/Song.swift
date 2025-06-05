//
//  MV.swift
//  MusicSimple
//
//  Created by xqsadness on 14/11/24.
//

import SwiftUI
import SwiftData

enum TypeImport: String, Codable, CaseIterable {
    case file = "File"
    case video = "Video"
    case library = "Music Library"
    case shareEX = "Other App"
    case `default` = "Default"
}

@Model
class Song {
    @Attribute(.unique) var videoID: String
    var thumbnail: String
    var title: String
    var length: Int
    var owner: String
    var dateAdd: Date
    var dateModified: Date
    var status: String
    var isFavorite: Bool
    var isLocally: Bool
    var isRecently: Bool
    var urlLocally: String
    var typeMedia: String
    var duration: String
    var typeImport: String
    
    var playlists: [PlayList] = []
    
    // Transient Properties
    @Transient var fileURL: URL? {
        return FileManager.getDocumentsDirectory().appendingPathComponent(title)
    }
    @Transient var fileNameWithoutExtension: String {
        return (title as NSString).deletingPathExtension
    }
    @Transient var fileExtension: String? {
        return (title as NSString).pathExtension.isEmpty ? nil : (title as NSString).pathExtension
    }
    
    // Init
    init(videoID: String = UUID().uuidString,
         thumbnail: String = "",
         title: String = "",
         length: Int = 0,
         owner: String = "",
         dateAdd: Date = Date(),
         dateModified: Date = Date(),
         status: String = "",
         isFavorite: Bool = false,
         isLocally: Bool = false,
         isRecently: Bool = false,
         isPrivate: Bool = false,
         urlLocally: String = "",
         typeMedia: String = "",
         duration: String = "",
         typeImport: TypeImport = .default) {
        self.videoID = videoID
        self.thumbnail = thumbnail
        self.title = title
        self.length = length
        self.owner = owner
        self.dateAdd = dateAdd
        self.dateModified = dateModified
        self.status = status
        self.isFavorite = isFavorite
        self.isLocally = isLocally
        self.isRecently = isRecently
        self.urlLocally = urlLocally
        self.typeMedia = typeMedia
        self.duration = duration
        self.typeImport = typeImport.rawValue
    }
}
