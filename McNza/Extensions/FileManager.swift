//
//  FileManager.swift
//  MusicSimple
//
//  Created by xqsadness on 14/11/24.
//

import SwiftUI
import AVFoundation

extension FileManager {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func uniqueFileURL(for url: URL) -> URL {
        var uniqueURL = url
        var counter = 1
        
        while fileExists(atPath: uniqueURL.path) {
            let filename = url.deletingPathExtension().lastPathComponent
            let fileExtension = url.pathExtension
            uniqueURL = url.deletingLastPathComponent()
                .appendingPathComponent("\(filename)(\(counter))")
                .appendingPathExtension(fileExtension)
            counter += 1
        }
        
        return uniqueURL
    }
    
    func getFileSize(url: URL) throws -> UInt64 {
        let attributes = try attributesOfItem(atPath: url.path)
        return attributes[.size] as! UInt64
    }
}
