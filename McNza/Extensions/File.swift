//
//  File.swift
//  McNza
//
//  Created by xqsadness4 on 5/6/25.
//


import SwiftUI
import AVFoundation

extension AVURLAsset {
    static func getAudioDuration(url: URL) -> Double {
        let asset = AVURLAsset(url: url)
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        return durationTime
    }
}

extension UInt64 {
    func formatFileSize() -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: Int64(self))
    }
}

extension String{
    var isEmptyOrWhiteSpace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
