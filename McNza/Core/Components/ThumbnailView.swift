//
//  ThumbnailView.swift
//  MusicSimple
//
//  Created by xqsadness4 on 15/11/24.
//

import SwiftUI
import AVFoundation

class ImageCache {
    static let shared = ImageCache()
    private var cache: [URL: UIImage] = [:]
    
    private init() {}
    
    func getImage(for url: URL) -> UIImage? {
        return cache[url]
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        cache[url] = image
    }
}

class ThumbnailViewModel: ObservableObject {
    @Published var thumbnail: UIImage? = nil
    
    func loadThumbnail(for url: URL?, maximumSize: CGSize) {
        guard let url = url else { return }
        
        if let cachedImage = ImageCache.shared.getImage(for: url) {
            self.thumbnail = cachedImage
            return
        }
        
        let fileExtension = url.pathExtension.lowercased()
        
        if ["mp4", "mov", "m4v"].contains(fileExtension) {
            if let generatedThumbnail = generateThumbnail(from: url, at: 1, maximumSize: maximumSize) {
                self.thumbnail = generatedThumbnail
                ImageCache.shared.setImage(generatedThumbnail, for: url)
            }
        } else if ["mp3", "wav", "aac"].contains(fileExtension) {
            self.thumbnail = nil
        }
    }
    
    private func generateThumbnail(from url: URL, at timeInSeconds: Double = 0, maximumSize: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = maximumSize
        
        let time = CMTime(seconds: timeInSeconds, preferredTimescale: 600)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            return image.resizedAndCropped(to: maximumSize)
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func generateThumbnail(from url: URL, at timeInSeconds: Double = 0, maximumSize: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = maximumSize
        
        let time = CMTime(seconds: timeInSeconds, preferredTimescale: 600)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            return image.resizedAndCropped(to: maximumSize)
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}

struct ThumbnailView: View {
    @StateObject private var viewModel = ThumbnailViewModel()
    
    var fileURL: URL?
    var placeholder: String = "defaultM"
    var frameSize: CGSize = CGSize(width: 145, height: 145)
    var maximumSize: CGSize = CGSize(width: 300, height: 300)
    
    var body: some View {
        ZStack {
            if let thumbnail = viewModel.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: frameSize.width, height: frameSize.height)
                    .cornerRadius(5)
            } else {
                Image(placeholder)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: frameSize.width, height: frameSize.height)
                    .foregroundColor(.gray)
                    .cornerRadius(5)
            }
        }
        .onAppear {
            viewModel.loadThumbnail(for: fileURL, maximumSize: maximumSize)
        }
    }
}

struct ThumbnailNoWidthView: View {
    @StateObject private var viewModel = ThumbnailViewModel()
    
    var fileURL: URL?
    var placeholder: String = "defaultM"
    var maximumSize: CGSize = CGSize(width: 300, height: 300)
    
    var body: some View {
        ZStack {
            if let thumbnail = viewModel.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Image(placeholder)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.loadThumbnail(for: fileURL, maximumSize: maximumSize)
        }
    }
}

extension UIImage {
    func resizedAndCropped(to size: CGSize) -> UIImage? {
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height
        let aspectRatio = max(aspectWidth, aspectHeight)

        let newSize = CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio)
        let origin = CGPoint(x: (newSize.width - size.width) / 2, y: (newSize.height - size.height) / 2)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: CGPoint(x: -origin.x, y: -origin.y), size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - SmartArtworkView

struct SmartArtworkView: View {
    let song: Song
    let size: CGSize
    let cornerRadius: CGFloat = 5

    var body: some View {
        Group {
            if let artwork = song.artwork {
                Image(uiImage: UIImage.fromData(artwork))
                    .resizable()
            } else if song.isVideo {
                ThumbnailView(fileURL: song.fileURL, frameSize: size)
            } else {
                Image(.defaultM)
                    .resizable()
            }
        }
        .scaledToFill()
        .frame(width: size.width, height: size.height)
        .cornerRadius(cornerRadius)
    }
}
