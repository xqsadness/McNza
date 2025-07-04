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
    private var cache: [String: UIImage] = [:]
    private let maxCacheSize = 100 // Maximum number of cached images
    
    private init() {}
    
    func getImage(for key: String) -> UIImage? {
        return cache[key]
    }
    
    func setImage(_ image: UIImage, for key: String) {
        // If cache is full, remove oldest entry
        if cache.count >= maxCacheSize {
            if let firstKey = cache.keys.first {
                cache.removeValue(forKey: firstKey)
            }
        }
        cache[key] = image
    }
}

class ThumbnailViewModel: ObservableObject {
    @Published var thumbnail: UIImage? = nil
    private let id: String
    
    init(id: String = UUID().uuidString) {
        self.id = id
    }
    
    func loadThumbnail(for url: URL?, maximumSize: CGSize) {
        guard let url = url else { return }
        
        // Create a unique cache key combining URL and size
        let cacheKey = "\(url.absoluteString)_\(maximumSize.width)_\(maximumSize.height)"
        
        if let cachedImage = ImageCache.shared.getImage(for: cacheKey) {
            self.thumbnail = cachedImage
            return
        }
        
        let fileExtension = url.pathExtension.lowercased()
        
        if ["mp4", "mov", "m4v"].contains(fileExtension) {
            if let generatedThumbnail = generateThumbnail(from: url, at: 1, maximumSize: maximumSize) {
                self.thumbnail = generatedThumbnail
                ImageCache.shared.setImage(generatedThumbnail, for: cacheKey)
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
    @StateObject private var viewModel: ThumbnailViewModel
    
    var fileURL: URL?
    var placeholder: String = "defaultM"
    var frameSize: CGSize = CGSize(width: 145, height: 145)
    var maximumSize: CGSize = CGSize(width: 300, height: 300)
    
    init(fileURL: URL?, placeholder: String = "defaultM", frameSize: CGSize = CGSize(width: 145, height: 145), maximumSize: CGSize = CGSize(width: 300, height: 300)) {
        self.fileURL = fileURL
        self.placeholder = placeholder
        self.frameSize = frameSize
        self.maximumSize = maximumSize
        // Create unique ID for each instance
        _viewModel = StateObject(wrappedValue: ThumbnailViewModel(id: "\(fileURL?.absoluteString ?? "")_\(maximumSize.width)_\(maximumSize.height)"))
    }
    
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
    @StateObject private var viewModel: ThumbnailViewModel
    
    var fileURL: URL?
    var placeholder: String = "defaultM"
    var maximumSize: CGSize = CGSize(width: 300, height: 300)
    
    init(fileURL: URL?, placeholder: String = "defaultM", maximumSize: CGSize = CGSize(width: 300, height: 300)) {
        self.fileURL = fileURL
        self.placeholder = placeholder
        self.maximumSize = maximumSize
        // Create unique ID for each instance
        _viewModel = StateObject(wrappedValue: ThumbnailViewModel(id: "\(fileURL?.absoluteString ?? "")_\(maximumSize.width)_\(maximumSize.height)"))
    }
    
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
    var maximumSize: CGSize = CGSize(width: 300, height: 300)
    
    var body: some View {
        Group {
            if let artwork = song.artwork {
                Image(uiImage: UIImage.fromData(artwork))
                    .resizable()
            } else if song.isVideo {
                ThumbnailView(fileURL: song.fileURL, frameSize: size, maximumSize: maximumSize)
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
