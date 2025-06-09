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
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 46, height: 46)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 70)
        }
    }
}

struct SongOptionsSheetView: View {
    
    @Environment(MainReelPlayerViewModel.self) var vm
    //Params
    let song: Song
    let songs: [Song]

    var body: some View {
        // Sheet content
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.3))
                .padding(.top, 8)
            
            ScrollView(.horizontal){
                HStack(spacing: 20) {
                    SheetActionItem(icon: "repeat", label: "Play Once"){
                        
                    }
                    
                    SheetActionItem(icon: "\(song.isFavorite ? "heart.slash" : "heart")", label: "\(song.isFavorite ? "Dislike" : "Like")"){
                        song.isFavorite.toggle()
                    }
                    SheetActionItem(icon: "circle", label: "Audio quality", action: {})
                    SheetActionItem(icon: "plus", label: "Add to playlist", action: {})
                    SheetActionItem(icon: "clock", label: "Sleep", action: {})
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .scrollIndicators(.hidden)
            
            Divider()
                .background(Color.white.opacity(0.15))
                .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Your Songs (\(songs.count)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                ScrollView{
                    LazyVStack(spacing: 0){
                        ForEach(songs) { item in
                            HStack {
                                // Artwork
                                SmartArtworkView(song: item, size: CGSize(width: 48, height: 48))
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
                                    vm.scrollPosition = item.id
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
    }
}
