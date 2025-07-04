//
//  MainReelPlayerViewModel.swift
//  McNza
//
//  Created by xqsadness on 9/6/25.
//

import SwiftUI
import SwiftData

@Observable
class MainReelPlayerViewModel{
    
    let player = PlayerService.shared
    var selectedFilter: FilterType = .all
    var currentIndex: Int = 0
    
}
