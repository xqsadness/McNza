//
//  MainReelPlayerViewModel.swift
//  McNza
//
//  Created by darktech4 on 9/6/25.
//

import SwiftUI
import SwiftData

@Observable
class MainReelPlayerViewModel{
    
    let player = PlayerService.shared
    var scrollPosition: Song.SongID?
    var selectedFilter: FilterType = .all
   
}
