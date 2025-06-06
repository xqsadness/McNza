//
//  URL.swift
//  MusicUISimple
//
//  Created by xqsadness4 on 6/2/25.
//

import SwiftUI
import AVFoundation

extension URL{
    @discardableResult
    func isVideo() -> Bool {
        if let typeIdentifier = try? self.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier {
            if let fileUTType = UTType(typeIdentifier) {
                if [
                    UTType.video,
                    UTType.quickTimeMovie,
                    UTType.mpeg4Movie,
                    UTType.movie
                ].contains(where: { fileUTType.conforms(to: $0) }) {
                    return true
                }
            }
        }
        return false
    }
}

extension UIImage {
    static func fromData(_ data: Data?) -> UIImage {
        guard let imageData = data, let image = UIImage(data: imageData) else {
            return UIImage()
        }
        return image
    }
}

extension URL {
    @discardableResult
    func createUnExitPath() -> URL {
        if !FileManager.default.fileExists(atPath: self.path) {
            do {
                try FileManager.default.createDirectory(atPath: self.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch let err{
                print("FileCenter/createUnExitPath err by -> \(err.localizedDescription)")
            }
        }
        
        return self
    }
    
    func isFolder() -> Bool? {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: self.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return true
            } else {
                return false
            }
        } else {
            return nil
        }
    }
}

extension UIImage {
    func resizedToFit(in targetSize: CGSize) -> UIImage? {
        let aspectWidth = targetSize.width / size.width
        let aspectHeight = targetSize.height / size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        let newSize = CGSize(width: size.width * aspectRatio, height: size.height * aspectRatio)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
extension URL {
    func generateThumbnail() -> UIImage? {
        do {
            let asset = AVURLAsset(url: self)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
