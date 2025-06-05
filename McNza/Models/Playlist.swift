//
//  PL.swift
//  MusicSimple
//
//  Created by xqsadness on 14/11/24.
//

import SwiftUI
import SwiftData

@Model
class PlayList {
    @Attribute(.unique) var playlistID: String
    var title: String
    var thumbnailSmall: String
    var thumbnailLarge: String
    var owner: String
    var publishedTime: Date
    var dateAdd: Date
    var dateModified: Date
    var isDefault: Bool
    var status: String
    var isPrivate: Bool
    
    @Relationship(deleteRule: .nullify, inverse: \Song.playlists)  var playlists = [Song]()
    
    init(playlistID: String = "",
         title: String = "",
         thumbnailSmall: String = "",
         thumbnailLarge: String = "",
         owner: String = "",
         publishedTime: Date = Date(),
         dateAdd: Date = Date(),
         dateModified: Date = Date(),
         isDefault: Bool = false,
         playlists: [Song] = [],
         status: String = "",
         isPrivate: Bool = false) {
        self.playlistID = playlistID
        self.title = title
        self.thumbnailSmall = thumbnailSmall
        self.thumbnailLarge = thumbnailLarge
        self.owner = owner
        self.publishedTime = publishedTime
        self.dateAdd = dateAdd
        self.dateModified = dateModified
        self.isDefault = isDefault
        self.playlists = playlists
        self.status = status
        self.isPrivate = isPrivate
    }
}
