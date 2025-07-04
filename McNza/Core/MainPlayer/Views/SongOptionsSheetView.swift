//
//  SongOptionsSheetView.swift
//  McNza
//
//  Created by xqsadness on 9/6/25.
//

import SwiftUI
import SwiftData

fileprivate struct SheetActionItem: View {
    let icon: String
    let label: String
    let action: () -> Void
    let isDestructive: Bool
    
    init(icon: String, label: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.action = action
        self.isDestructive = isDestructive
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isDestructive ? .red : .white)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 46, height: 46)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
                Text(label)
                    .font(.caption)
                    .foregroundColor(isDestructive ? .red : .white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 70)
        }
    }
}

struct SongOptionsSheetView: View {
    
    @Environment(MainReelPlayerViewModel.self) var vm
    @Environment(\.modelContext) private var modelContext
    //Params
    let song: Song
    let songs: [Song]
    let scrollReader: ScrollViewProxy
    @State private var showDeleteAlert = false
    
    var body: some View {
        // Sheet content
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.3))
                .padding(.top, 8)
            
            ScrollView(.horizontal){
                HStack(spacing: 20) {
                    SheetActionItem(
                        icon: vm.player.isRepeating ? "repeat.1" : "repeat",
                        label: vm.player.isRepeating ? "Repeat One" : "Play Once"
                    ) {
                        vm.player.toggleRepeat()
                    }
                    SheetActionItem(icon: "\(song.isFavorite ? "heart.slash" : "heart")", label: "\(song.isFavorite ? "Dislike" : "Like")"){
                        song.isFavorite.toggle()
                    }
                    SheetActionItem(icon: "text.line.first.and.arrowtriangle.forward", label: "Add to queue") {
                        vm.player.addToQueue(song: song)
                    }
                    SheetActionItem(icon: "plus", label: "Add to playlist", action: {})
                    SheetActionItem(icon: "clock", label: "Sleep", action: {})
                    SheetActionItem(icon: "info.circle", label: "Information", action: {})
                    SheetActionItem(icon: "square.and.arrow.up", label: "Share", action: {})
                    SheetActionItem(
                        icon: "trash.fill",
                        label: "Delete",
                        isDestructive: true
                    ) {
                        showDeleteAlert = true
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .scrollIndicators(.hidden)
            
            Divider()
                .background(Color.white.opacity(0.15))
                .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Your Songs (\(songs.count))")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                ScrollView{
                    LazyVStack(spacing: 0){
                        ForEach(songs) { item in
                            HStack {
                                // Artwork
                                SmartArtworkView(song: item, size: CGSize(width: 48, height: 48), maximumSize: CGSize(width: 99, height: 99))
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 6.5) {
                                    Text(item.fileNameWithoutExtension)
                                        .lineLimit(1)
                                        .font(.system(size: 16)).bold()
                                        .foregroundColor(.primary)
                                    
                                    Text(item.artist.isEmpty ? "Artist: <unknown>" : "Artist: \(song.artist)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if vm.player.currentTrack?.id == item.id {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(
                                vm.player.currentTrack?.id == item.id ?
                                Color.accentColor.opacity(0.11) : Color.clear
                            )
                            .contentShape(.rect)
                            .onTapGesture{
                                withAnimation(.spring) {
                                    vm.selectedFilter = .all
                                    scrollReader.scrollTo(item.id, anchor: .center)
                                    vm.player.play(song: item, in: songs)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 8)
            
            Button{
                Coordinator.shared.dismissSheet()
            }label: {
                Text("Cancel")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color(.secondarySystemBackground).opacity(0.65))
                    .safeAreaPadding(.bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationDetents([.medium])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(17)
        .ignoresSafeArea(edges: .bottom)
        .alert("Delete Song", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteSong()
            }
        } message: {
            Text("Are you sure you want to delete this song? This action cannot be undone.")
        }
    }
    
    private func deleteSong() {
        // Delete file from documents
        if let fileURL = song.fileURL{
            if FileManagerService.shared.deleteFile(at: fileURL) {
                // If file deletion successful, delete from SwiftData
                modelContext.delete(song)
                // Close the sheet
                Coordinator.shared.dismissSheet()
                // Show success message
                Toast.shared.present(title: "Song deleted successfully")
            } else {
                Toast.shared.present(title: "Error deleting song file")
            }
        }
    }
}
