//
//  songService.swift
//  MusicUISimple
//
//  Created by xqsadness4 on 6/2/25.
//

import UIKit
import AVFoundation
import MediaPlayer

final class MetadataService {
    enum Errors: Error { case invalid }
    typealias song = Song
    // from uri
    static func getMetaData(uri: URL) async -> song {
        let song: song = .init()
        let filenamed = uri.deletingPathExtension().lastPathComponent
        song.dir = uri.lastPathComponent
        let avplayeritem = AVPlayerItem(url: uri)
        if let metadataList = try? await avplayeritem.asset.load(.metadata) as [AVMetadataItem] {
            if avplayeritem.duration.isValid {
                let durationInSeconds = CMTimeGetSeconds(avplayeritem.duration)
                song.duration = durationInSeconds
            }
            //if let lyric = try? await avplayeritem.asset.load(.lyrics) { song.lyric = lyric }
            for metadata in metadataList {
                guard let value = try? await metadata.load(.value) else {
                    continue
                }
                if let key = metadata.commonKey?.rawValue {
                    print("\(#function) \(key): \(value)")
                    switch key {
                    case "title" : song.title = value as? String ?? filenamed
                    case "artist": song.artist = value as? String ?? ""
                    case "albumName": song.albumName = value as? String ?? ""
                    case "artwork": if let artwork = value as? Data {
                        song.artwork = artwork
                    }
                    case "copyrights": song.copyrights = value as? String ?? ""
                    default: continue
                    }
                } else {
                }
            }
        }
        return song
    }
    
    // from apple music
    static func getMetaData(metamusic: MPMediaItem) -> song {
        var song: song = .init()
        if let title = metamusic.title { song.title = title }
        if let artist = metamusic.artist { song.artist = artist }
        if let albumName = metamusic.albumTitle { song.albumName = albumName }
        if let artwork = metamusic.artwork {
            song.artwork = artwork.image(at: CGSize(width: 300, height: 300))?.pngData()
        }
        return song
    }
    
    static func getUIImage(uri: URL) async -> UIImage? {
        let avplayeritem = AVPlayerItem(url: uri)
        if let metadataList = try? await avplayeritem.asset.load(.metadata) as [AVMetadataItem] {
            for metadata in metadataList {
                guard let key = metadata.commonKey?.rawValue,
                      let value = try? await metadata.load(.value) else {
                    continue
                }
                if key == "artwork" {
                    if let artwork = value as? Data { return UIImage(data: artwork) }
                }
            }
        }
        return nil
    }
    
    static func videoExport(uri: URL, completion: @escaping (Bool, song?) -> Void) async {
        do {
            let namedOfFile = uri.deletingPathExtension().lastPathComponent
            let infoMETA = await MetadataService.getMetaData(uri: uri)
            if let videoThumb = uri.generateThumbnail()?.resizedToFit(in: .init(width: 320, height: 320)) {
                let innerURI = FileManager.getDocumentsDirectory().appendingPathComponent("\(namedOfFile + "\(Int.random(in: 0...9999))").mov", conformingTo: .fileURL)
                let inputURL = URL(fileURLWithPath: uri.path)
                if !FileManager.default.fileExists(atPath: inputURL.path) { throw Errors.invalid }
                let asset = AVURLAsset(url: inputURL, options: .none)
                var inputs = [AVMutableMetadataItem]()
                
                let metainputTitle = AVMutableMetadataItem()
                metainputTitle.key = AVMetadataKey.commonKeyTitle as (NSCopying & NSObjectProtocol)?
                metainputTitle.keySpace = .common
                let metainputArtist = AVMutableMetadataItem()
                metainputArtist.key = AVMetadataKey.commonKeyArtist as (NSCopying & NSObjectProtocol)?
                metainputArtist.keySpace = .common
                let metainputAlbum = AVMutableMetadataItem()
                metainputAlbum.key = AVMetadataKey.commonKeyAlbumName as (NSCopying & NSObjectProtocol)?
                metainputAlbum.keySpace = .common
                let metainputCopy = AVMutableMetadataItem()
                metainputCopy.key = AVMetadataKey.commonKeyCopyrights as (NSCopying & NSObjectProtocol)?
                metainputCopy.keySpace = .common
                let metainputArtwork = AVMutableMetadataItem()
                metainputArtwork.locale = .current
                metainputArtwork.identifier = .commonIdentifierArtwork
                metainputArtwork.value = videoThumb.jpegData(compressionQuality: 1.0) as (any NSCopying & NSObjectProtocol)?
                
                inputs.append(metainputTitle)
                inputs.append(metainputArtist)
                inputs.append(metainputAlbum)
                inputs.append(metainputCopy)
                inputs.append(metainputArtwork)
                
                guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
                    print("[ERR] exportSession")
                    return
                }
                let outputURL = URL(fileURLWithPath: innerURI.path)
                exportSession.outputURL = outputURL
                exportSession.outputFileType = .mov
                exportSession.metadata = inputs
                exportSession.shouldOptimizeForNetworkUse = true
                let start = CMTime(seconds: 0.0, preferredTimescale: 600)
                let range = CMTimeRange(start: start, duration: asset.duration)
                exportSession.timeRange = range
                exportSession.exportAsynchronously {
                    switch exportSession.status {
                    case .completed:
                        var song: song = .init()
                        song.title = infoMETA.title
                        if song.title == "" { song.title = innerURI.lastPathComponent }
                        song.artist = infoMETA.artist
                        song.albumName = infoMETA.albumName
                        song.copyrights = infoMETA.copyrights
                        song.dir = innerURI.lastPathComponent
                        //                        song.videoID = .init()
                        completion(true, song)
                        
                    case .failed:
                        if let error = exportSession.error { completion(false, nil); print("[ERR][\(#function)] \(error)") }
                    case .cancelled:
                        print("[ERR][\(#function)] cancelled")
                        completion(false, nil)
                    default:
                        completion(false, nil)
                        break
                    }
                }
            }
        }
        catch {
            print("[ERR][\(#function)] \(error.localizedDescription)")
        }
    }
}
