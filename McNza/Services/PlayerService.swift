//
//  PlayerService.swift
//  McNza
//
//  Created by xqsadness4 on 6/6/25.
//

import Foundation
import AVFoundation
import MediaPlayer

@Observable
class PlayerService: NSObject {
    static let shared = PlayerService()
    
    // MARK: - Private Properties
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var sleepTimer: Timer?
    private var sleepStartTime: Date?
    private var sleepPausedTime: Date?
    
    // MARK: - Public Properties
    var currentIndex: Int = 0
    var isLandscape: Bool = false
    var isPlaying: Bool = false
    var isRepeating: Bool = false
    var isSleeping: Bool = false
    
    var isVideoEnabled: Bool = false
    
    var playlist: [Song] = [] {
        didSet {
            nextTrack = getNextSong()
        }
    }
    
    var currentTrack: Song? = nil
    var nextTrack: Song? = nil
    var duration: Double = 0.0
    var progress: Double = 0.0
    var currentTime: Double = 0.0
    
    // Sleep-related properties
    var totalSleepDuration: Int = 0
    var elapsedSleepTime: Int = 0
    
    // Command center information
    var nowPlayingInfo: [String: Any] = [:]
    
    // MARK: - Initialization
    private override init() {
        super.init()
        setupAudioSession()
//        setupRemoteCommandCenter()
    }
    
    // MARK: - Audio and Video Setup
    
    /// Configures the audio session for playback.
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Playback Controls
    
    func play(song: Song, in playlist: [Song] = []) {
        if let existingTrack = currentTrack, existingTrack.videoID == song.videoID {
            if isPlaying {
                pause()
            } else {
                player?.play()
                isPlaying = true
                resumeSleepTimer()
            }
            return
        }
        
        if playlist.isEmpty {
            self.playlist = [song]
            self.currentIndex = 0
        } else {
            self.playlist = playlist
            self.currentIndex = playlist.firstIndex(where: { $0.videoID == song.videoID }) ?? 0
        }
        currentTrack = self.playlist[currentIndex]
        playCurrentTrack()
        
        // Save the track as recently played
        if let index = self.playlist.firstIndex(where: { $0.videoID == song.videoID }) {
            self.playlist[index].isRecently = true
            self.playlist[index].dateModified = Date()
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        pauseSleepTimer()
    }
    
    /// Stops the current playback.
    private func stop() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        isPlaying = false
        removePlayerObservers()
    }
    
    /// Plays the current track.
    private func playCurrentTrack() {
        guard let track = currentTrack else {
            isPlaying = false
            return
        }
        let url = track.fileURL ?? URL(fileURLWithPath: "")
        let playerItem = AVPlayerItem(url: url)
        
        if currentTrack?.isVideo == false {
            isVideoEnabled = false
        }
        
        nextTrack = getNextSong(count: 1)
        stop()
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        isPlaying = true
        
        addTimeObserver()
//        updateNowPlayingInfo()
        addPlayerObservers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(trackDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    /// Moves to the next track in the playlist.
    func next() {
        guard !playlist.isEmpty else {
            playCurrentTrack()
            return
        }
        
        if let currentTrackIndex = playlist.firstIndex(where: { $0.videoID == currentTrack?.videoID }) {
            currentIndex = (currentTrackIndex + 1) % playlist.count
            currentTrack = playlist[currentIndex]
            playCurrentTrack()
        } else {
            currentIndex = 0
            currentTrack = playlist[currentIndex]
            playCurrentTrack()
        }
        addPlayerObservers()
    }
    
    /// Moves to the previous track in the playlist.
    func previous() {
        if playlist.isEmpty {
            playCurrentTrack()
            return
        }
        
        stop()
        currentIndex = (currentIndex - 1 + playlist.count) % playlist.count
        currentTrack = playlist[currentIndex]
        playCurrentTrack()
        addPlayerObservers()
    }
    
    func seek(to time: Double) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: targetTime)
    }
    
    func addToQueue(song: Song) {
        guard let currentTrack = currentTrack else {
            Toast.shared.present(title: "No track is currently playing.")
            return
        }
        
        // Check if the song is already in the playlist
        if let existingIndex = playlist.firstIndex(where: { $0.videoID == song.videoID }) {
            // Remove the track from its current position
            playlist.remove(at: existingIndex)
            // Find the index of the currently playing track
            if let currentTrackIndex = playlist.firstIndex(where: { $0.videoID == currentTrack.videoID }) {
                // Insert the track immediately after the current track
                playlist.insert(song, at: currentTrackIndex + 1)
            } else {
                // If the current track is not found (unexpected case), add the track to the end of the playlist
                playlist.append(song)
            }
            Toast.shared.present(title: "Moved \"\(song.title)\" to play next.")
        } else {
            // If the track is not in the playlist, add it right after the current track
            if let currentTrackIndex = playlist.firstIndex(where: { $0.videoID == currentTrack.videoID }) {
                playlist.insert(song, at: currentTrackIndex + 1)
            } else {
                playlist.append(song)
            }
            Toast.shared.present(title: "Added \"\(song.title)\" to the queue.")
        }
        
        addPlayerObservers()
    }
    
    func getPlayer() -> AVPlayer? {
        return player
    }
    
    func toggleRepeat() {
        isRepeating.toggle()
        nextTrack = getNextSong()
    }
    
    // MARK: - Sleep Timer
    
    /// Sets a sleep timer to pause playback after a duration.
    func setSleepTimer(duration: TimeInterval) {
        isSleeping = true
        totalSleepDuration = Int(duration)
        elapsedSleepTime = 0
        sleepStartTime = Date()
        sleepTimer?.invalidate()
        sleepTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.pause()
            self?.cancelSleepTimer()
        }
    }
    
    /// Pauses the sleep timer.
    func pauseSleepTimer() {
        sleepPausedTime = Date()
        sleepTimer?.invalidate()
    }
    
    /// Resumes the sleep timer.
    func resumeSleepTimer() {
        guard let pausedTime = sleepPausedTime, let startTime = sleepStartTime else { return }
        let remainingTime = totalSleepDuration - Int(pausedTime.timeIntervalSince(startTime))
        setSleepTimer(duration: TimeInterval(remainingTime))
    }
    
    /// Cancels the sleep timer.
    func cancelSleepTimer() {
        isSleeping = false
        totalSleepDuration = 0
        elapsedSleepTime = 0
        sleepStartTime = nil
        sleepPausedTime = nil
        sleepTimer?.invalidate()
        sleepTimer = nil
    }
    
    // MARK: - Notification Handlers
    
    /// Handles track completion events.
    @objc private func trackDidFinish() {
        if isRepeating {
            playCurrentTrack()
        } else {
            next()
        }
    }
    
    // MARK: - Observers
    
    /// Adds observers to monitor player state.
    private func addPlayerObservers() {
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .initial], context: nil)
    }
    
    /// Removes observers from the player.
    private func removePlayerObservers() {
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "timeControlStatus" else { return }
        
        if let player = object as? AVPlayer {
            DispatchQueue.main.async {
                self.isPlaying = player.timeControlStatus == .playing
            }
        }
    }
    
    // MARK: - Helpers
    
    /// Gets the next track in the playlist.
    func getNextSong(count: Int = 1) -> Song? {
        guard !playlist.isEmpty else { return nil }
        
        if isRepeating {
            return currentTrack
        } else {
            if let currentTrackIndex = playlist.firstIndex(where: { $0.videoID == currentTrack?.videoID }) {
                let nextIndex = (currentTrackIndex + count) % playlist.count
                return playlist[nextIndex]
            } else {
                return playlist.first
            }
        }
    }
    
    private func addTimeObserver() {
        guard let player = player else { return }
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self else { return }
            
            self.duration = player.currentItem?.duration.seconds ?? 0.0
            self.currentTime = player.currentTime().seconds
            self.progress = self.currentTime / (self.duration > 0 ? self.duration : 1.0)
            
            if self.isSleeping, let startTime = self.sleepStartTime {
                self.elapsedSleepTime = Int(Date().timeIntervalSince(startTime))
            }
            
//            self.updateNowPlayingInfo()
        }
    }
}
