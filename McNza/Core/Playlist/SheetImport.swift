//
//  SheetImport.swift
//  McNza
//
//  Created by xqsadness4 on 5/6/25.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData
import AVFoundation

struct SheetImport: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var app = AppSettings.shared
    @State private var vm = SheetImportViewModel()
    
    var body: some View {
        ZStack{
            Color.backgroundPopup
            
            VStack(alignment: .leading, spacing: 14){
                Text("Import Music")
                    .hSpacing(.center)
                    .padding(.bottom,7)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                            .bold()
                            .onTapGesture {
                                Coordinator.shared.dismissSheet()
                            }
                    }
                
                customButton("icFile", "Import From File", "Make songs from your local files"){
                    vm.isImporterPresented.toggle()
                }
                
                customButton("icGallery", "Import From Video", "Convert video soundtracks into song"){
                    vm.isPickerPresented.toggle()
                }
                
                //                customButton("icAppleMusic", "Import From Apple Music", "Import songs from your Apple Music library"){
                //                    Coordinator.shared.dismissSheet()
                //                    Coordinator.shared.navigateTo(
                //                        AppleMusic()
                //                    )
                //                }
            }
            .vSpacing(.top)
            .padding(15)
            .fileImporter(
                isPresented: $vm.isImporterPresented,
                allowedContentTypes: [.audio, .video, .movie]
            ) { (res) in
                vm.handleFilesImport(res: res)
            }
            .sheet(isPresented: $vm.isPickerPresented) {
                VideoPicker(sourceType: .photoLibrary, mediaTypes: [
                    UTType.movie.identifier,
                    UTType.audio.identifier
                ]) { result in
                    switch result {
                    case .success(let url):
                        vm.handlePhotoImport(url: url)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 270)
        .clipShape(.rect(cornerRadius: 30))
        .padding(.horizontal, 15)
        .onAppear{ withAnimation(.bouncy){app.isBlur = true}}
        .onDisappear{ withAnimation(.bouncy){app.isBlur = false}}
        .presentationDetents([.height(270)])
        .presentationBackground(.clear)
        .onAppear{
            vm.modelContext = modelContext
        }
    }
    
    @ViewBuilder
    func customButton(_ img: String,_ title: String,_ subTitle: String = "" ,onTap: @escaping () -> Void) -> some View{
        HStack(spacing: 13){
            Image(img)
                .resizable()
                .frame(width: 35, height: 35)
                .clipShape(.circle)
            
            VStack(spacing: 6){
                Text(title)
                    .hSpacing(.leading)
                    .lineLimit(1)
                
                if !subTitle.isEmpty{
                    Text(subTitle)
                        .hSpacing(.leading)
                        .lineLimit(1)
                }
            }
            .hSpacing(.leading)
        }
        .hSpacing(.leading)
        .padding(10)
        .background{
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 1)
        }
        .contentShape(.rect)
        .onTapGesture {
            onTap()
        }
    }
}

@Observable
class SheetImportViewModel {
    var modelContext: ModelContext? = nil
    
    //view props
    var isImporterPresented = false
    var isPickerPresented = false
    var isOptionViewPresented = false
    var selectedMV: Song = .init()
    
    //MARK: Func handler
    func handleFilesImport(res :Result<URL, any Error>){
        if let dirOriginAlbums = try? res.get() {
            let toURL = FileManager.getDocumentsDirectory()
            FileManager
                .copyFile(
                    from: dirOriginAlbums,
                    to: toURL,
                    autoLoop: true,
                    completionDeleteOriginDir: false,
                    completion: { innerURI, isSuccess in
                        if isSuccess {
                            if let innerURI = innerURI {
                                let duration = AVURLAsset.getAudioDuration(url: innerURI)
                                if innerURI.isVideo() {
                                    Task {
                                        await MetadataService.videoExport(uri: innerURI) { [self] status, mmusic in
                                            if let mmusic = mmusic, status == true {
                                                mmusic.duration = duration
                                                addToModelContext(mmusic, context: self.modelContext)
                                                Toast.shared.present(title: "Import \(mmusic.title) successfully")
                                                try? FileManager.default.removeItem(atPath: innerURI.path)
                                            }
                                        }
                                    }
                                } else {
                                    Task {
                                        let mmusic = await MetadataService.getMetaData(uri: innerURI)
                                        if mmusic.title == "" { mmusic.title = innerURI.lastPathComponent }
                                        mmusic.duration = duration
                                        self.addToModelContext(mmusic, context:  self.modelContext)
                                        Toast.shared.present(title: "Import \(mmusic.title) successfully")
                                    }
                                }
                            }
                        }
                    },
                    coordinator: true,
                    isUUIDLast: false
                )
        }
    }
    
    func handlePhotoImport(url: URL) {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            var destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
            
            // Check and rename the file if necessary
            destinationURL = FileManager.default.uniqueFileURL(for: destinationURL)
            
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            let duration = AVURLAsset.getAudioDuration(url: destinationURL)
            
            Task {
                let mmusic = await MetadataService.getMetaData(uri: url)
                if mmusic.title == "" { mmusic.title = url.lastPathComponent }
                mmusic.dir = url.lastPathComponent
                mmusic.duration = duration
                
                modelContext?.insert(mmusic)
                Toast.shared.present(title: "Import \(mmusic.title) successfully")
            }
        } catch {
            print("Error import file: \(error.localizedDescription)")
        }
    }
    
    private func addToModelContext<T: PersistentModel>(_ object: T, context: ModelContext?) {
        do {
            context?.insert(object)
            try context?.save()
        } catch {
            print("Failed to add \(T.self) to the context: \(error.localizedDescription)")
        }
    }
}
