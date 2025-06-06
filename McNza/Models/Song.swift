//
//  MV.swift
//  MusicSimple
//
//  Created by xqsadness on 14/11/24.
//

import SwiftUI
import SwiftData

@Model
class Song {
    @Attribute(.unique) var videoID: String
    var title: String
    var length: Int
    var owner: String
    var dateAdd: Date
    var dateModified: Date
    var status: String
    var isFavorite: Bool
    var isRecently: Bool
    var duration: Double
    
    var artist: String
    var albumName: String
    var copyrights: String
    var artwork: Data? = nil
    var dir: String = ""
    
    var playlists: [PlayList] = []
    
    // Transient Properties
    @Transient var fileURL: URL? {
        return FileManager.getDocumentsDirectory().appendingPathComponent(dir)
    }
    @Transient var isVideo: Bool {
        return FileManager.getDocumentsDirectory().appendingPathComponent(dir).isVideo()
    }
    @Transient var fileNameWithoutExtension: String {
        return (dir as NSString).deletingPathExtension
    }
    @Transient var fileExtension: String? {
        return (dir as NSString).pathExtension.isEmpty ? nil : (dir as NSString).pathExtension
    }
    
    // Init
    init(videoID: String = UUID().uuidString,
         title: String = "",
         length: Int = 0,
         owner: String = "",
         dateAdd: Date = Date(),
         dateModified: Date = Date(),
         status: String = "",
         isFavorite: Bool = false,
         isRecently: Bool = false,
         duration: Double = .zero,
         artist: String = "",
         albumName: String = "",
         copyrights: String = "") {
        self.videoID = videoID
        self.title = title
        self.length = length
        self.owner = owner
        self.dateAdd = dateAdd
        self.dateModified = dateModified
        self.status = status
        self.isFavorite = isFavorite
        self.isRecently = isRecently
        self.duration = duration
        self.artist = artist
        self.albumName = albumName
        self.copyrights = copyrights
    }
}
