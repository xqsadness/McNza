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
    
    static func copyFile(
        from url: URL,
        to toFolder: URL,
        autoLoop: Bool,
        completionDeleteOriginDir: Bool,
        completion: @escaping ((URL?, Bool) -> Void),
        coordinator: Bool,
        isUUIDLast: Bool
    ) {
        guard url.isFileURL else {
            print("[FILE] url is not file")
            completion(nil, false)
            return
        }
        guard toFolder.isFolder() == true else {
            print("[FILE] to-url is not folder")
            completion(nil, false)
            return
        }
        let copyClosure: (_ urlBlock: URL, _ urlOrigin: URL) -> Bool = { urlBlock, urlOrigin in
            do {
                try FileManager.default.copyItem(
                    at: urlOrigin,
                    to: toFolder.appendingPathComponent(urlBlock.lastPathComponent, conformingTo: .fileURL)
                )
                completion(toFolder.appendingPathComponent(urlBlock.lastPathComponent, conformingTo: .fileURL), true)
                return true
            } catch {
                if coordinator {
                    guard urlOrigin.startAccessingSecurityScopedResource() else {
                        var result = false
                        let coordinator = NSFileCoordinator()
                        var error: NSError? = nil
                        coordinator.coordinate(readingItemAt: urlOrigin, options: [], error: &error) { (url) -> Void in
                            do {
                                try FileManager.default.copyItem(
                                    at: urlOrigin,
                                    to: toFolder.appendingPathComponent(urlBlock.lastPathComponent, conformingTo: .fileURL)
                                )
                                completion(toFolder.appendingPathComponent(urlBlock.lastPathComponent, conformingTo: .fileURL), true)
                            } catch {
                                print("[FILE] FileManager Cannot copy \(error)")
                            }
                            result = true
                            urlOrigin.stopAccessingSecurityScopedResource()
                        }
                        return result
                    }
                    var result = false
                    let coordinator = NSFileCoordinator()
                    var error: NSError? = nil
                    coordinator.coordinate(readingItemAt: urlOrigin, options: [], error: &error) { (url) -> Void in
                        do {
                            try FileManager.default.copyItem(
                                at: urlOrigin,
                                to: toFolder.appendingPathComponent(urlBlock.lastPathComponent, conformingTo: .fileURL)
                            )
                            completion(toFolder.appendingPathComponent(urlBlock.lastPathComponent, conformingTo: .fileURL), true)
                        } catch {
                            print("[FILE] FileManager Cannot copy \(error)")
                        }
                        result = true
                        urlOrigin.stopAccessingSecurityScopedResource()
                    }
                    
                    urlOrigin.stopAccessingSecurityScopedResource()
                    return result
                    
                }
                print("[FILE] FileManager Cannot copy \(error)")
                return false
            }
        }
        if isUUIDLast {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm:ss"
            let timerString = formatter.string(from: Date())
            
            let destinationURLToFolder = toFolder
                .appendingPathComponent("\(url.deletingPathExtension().lastPathComponent)-\(timerString).\(url.pathExtension)", conformingTo: .fileURL)
            
            let copyCompletion = copyClosure(destinationURLToFolder, url)
            if copyCompletion && completionDeleteOriginDir {
                do {
                    try FileManager.default.removeItem(atPath: url.path)
                    print("[FILE] copyFile completionDeleteOriginDir")
                } catch {
                    print("[FILE] copyFile Cannot delete completionDeleteOriginDir by:\(error.localizedDescription)")
                }
            }
        } else if autoLoop {
            var copyURL = url
            copyURL.deletePathExtension()
            var destinationURL = copyURL.lastPathComponent
            do {
                let contentsInDestinationFolder = try FileManager.default.contentsOfDirectory(atPath: toFolder.path)
                var whileLoopCount = 0
                var isWhileLoopRunning = true
                var copiedFolderPrefix = "copy"
                while isWhileLoopRunning {
                    if (whileLoopCount > 1) { copiedFolderPrefix = "copy(\(whileLoopCount - 1))" }
                    let whileRequired = contentsInDestinationFolder.filter { $0 == "\(destinationURL).\(url.pathExtension)" }
                    if(!whileRequired.isEmpty) {
                        destinationURL = "\(copyURL.lastPathComponent) \(copiedFolderPrefix)"
                        whileLoopCount += 1
                    }
                    if(whileRequired.isEmpty){
                        isWhileLoopRunning = false
                    }
                }
                let destinationURLToFolder = toFolder
                    .appendingPathComponent("\(destinationURL).\(url.pathExtension)", conformingTo: .fileURL)
                
                let copyCompletion =  copyClosure(destinationURLToFolder, url)
                if copyCompletion && completionDeleteOriginDir {
                    do {
                        try FileManager.default.removeItem(atPath: url.path)
                        print("[FILE] copyFile completionDeleteOriginDir")
                    } catch {
                        print("[FILE] copyFile Cannot delete completionDeleteOriginDir by:\(error.localizedDescription)")
                    }
                }
            } catch {
                print("[FILE] copyFile autoLoop error by: \(error.localizedDescription)")
            }
        } else {
            let destinationURLToFolder = toFolder
                .appendingPathComponent("\(url.lastPathComponent)", conformingTo: .fileURL)
            let copyCompletion = copyClosure(destinationURLToFolder, url)
            if copyCompletion && completionDeleteOriginDir {
                do {
                    try FileManager.default.removeItem(atPath: url.path)
                    print("[FILE] copyFile completionDeleteOriginDir")
                } catch {
                    print("[FILE] copyFile Cannot delete completionDeleteOriginDir by:\(error.localizedDescription)")
                }
            }
        }
    }
}
