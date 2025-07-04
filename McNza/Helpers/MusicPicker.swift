//
//  MusicPicker.swift
//  McNza
//
//  Created by xqsadness on 4/7/25.
//

import SwiftUI
import MediaPlayer
import SwiftData

struct MusicAuthorizationView: View {
    var onAuthorized: () -> Void
    
    var body: some View {
        ZStack {
            // Background with blur effect
            Color.black.opacity(0.02)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Top Card
                VStack(spacing: 20) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .blue.opacity(0.3), radius: 15)
                    
                    VStack(spacing: 8) {
                        Text("Access Required")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .primary.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("To enhance your music experience")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 40)
                
                // Permission Card
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Media Library Permission")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Access your music library")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(20)
                    .background(.gray.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Bottom Buttons
                VStack(spacing: 16) {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Go to setting")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [.accentColor, .accentColor.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Button {
                        onAuthorized()
                    } label: {
                        Text("Check Again")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemBackground))
    }
}

struct MusicPicker: View {
    @Binding var isPresent: Bool
    var modelContext: ModelContext? = nil
    @State private var authorizationStatus: MPMediaLibraryAuthorizationStatus = .notDetermined
    
    var body: some View {
        Group {
            switch authorizationStatus {
            case .authorized:
                VStack {
                    UIMusicPickerController(
                        onExport: { assetInput in
                            let uuid = UUID().uuidString
                            let toDIR = FileManager.getDocumentsDirectory().appendingPathComponent("\(uuid).m4a", conformingTo: .fileURL)
                            let onErr = {
                                print("Error, Can't import media")
                            }
                            guard let url = assetInput.assetURL else { onErr(); return false }
                            let assetURL = AVURLAsset(url: url)
                            guard let exporter = AVAssetExportSession(asset: assetURL, presetName: AVAssetExportPresetAppleM4A) else {
                                return false
                            }
                            exporter.outputURL = toDIR
                            exporter.outputFileType = .m4a
                            exporter.exportAsynchronously {
                                if exporter.status == .completed {
                                    print("[\(#fileID)] line: \(#line), URI(\(exporter.status) && \(assetInput.title ?? "Unknown Song")")
                                    DispatchQueue.main.async {
                                        let songTitle = assetInput.title ?? uuid
                                        let song = Song(
                                            videoID: uuid,
                                            title: songTitle,
                                            length: 0,
                                            owner: "Apple Music",
                                            dateAdd: Date(),
                                            dateModified: Date(),
                                            status: "",
                                            isFavorite: false,
                                            isRecently: false,
                                            duration: assetURL.duration.seconds,
                                            artist: assetInput.artist ?? "Unknown Artist",
                                            albumName: assetInput.albumTitle ?? "Unknown Album",
                                            copyrights: ""
                                        )
                                        song.dir = toDIR.lastPathComponent
                                        
                                        modelContext?.insert(song)
                                        Toast.shared.present(title: "Import \(song.title) successfully")
                                    }
                                }
                            }
                            return true
                        },
                        onDidCancel: {
                            DispatchQueue.main.async { isPresent = false }
                        }
                    )
                }
                .ignoresSafeArea()
                
            case .denied, .restricted:
                MusicAuthorizationView {
                    checkAuthorization()
                }
                
            case .notDetermined:
                Color.clear
                    .onAppear {
                        requestAuthorization()
                    }
            @unknown default:
                Text("Unknown authorization status")
            }
        }
        .onAppear {
            checkAuthorization()
        }
    }
    
    private func checkAuthorization() {
        authorizationStatus = MPMediaLibrary.authorizationStatus()
    }
    
    private func requestAuthorization() {
        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                authorizationStatus = status
            }
        }
    }
}

fileprivate struct UIMusicPickerController: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var onExport: (_ music: MPMediaItem) -> Bool
    var onDidCancel: () -> Void
    
    class Coordinator: NSObject, UINavigationControllerDelegate, MPMediaPickerControllerDelegate {
        var parent: UIMusicPickerController
        init(_ parent: UIMusicPickerController) {
            self.parent = parent
        }
        
        func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            let selectedSong = mediaItemCollection.items
            if (selectedSong.count) > 0 {
                let songItem = selectedSong[0]
                parent.onExport(songItem)
            }
        }
        
        func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
            parent.onDidCancel()
            mediaPicker.dismiss(animated: true, completion: { })
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<UIMusicPickerController>) -> MPMediaPickerController {
        let picker = MPMediaPickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: UIViewControllerRepresentableContext<UIMusicPickerController>) {
    }
}

