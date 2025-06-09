//
//  SwiftUIView.swift
//  McNza
//
//  Created by xqsadness on 5/6/25.
//

import SwiftUI
import SwiftData

struct MainReelPlayerView: View {
    
    //Vm
    @Environment(MainReelPlayerViewModel.self) var vm
    //View props
    @Query(sort: \Song.dateAdd, order: .reverse) var songs: [Song]
    @Query(filter: #Predicate { $0.isFavorite == true }, sort: \Song.dateModified, order: .reverse) var favSongs: [Song]
    @State private var currentIndex: Int = 0
    
    var displayedSongs: [Song] {
        switch vm.selectedFilter {
        case .all:
            return songs
        case .favorite:
            return favSongs
        case .recent:
            return songs
        }
    }
    
    var body: some View {
        @Bindable var vmBinding = vm
        GeometryReader { proxy in
            let screenHeight = proxy.size.height
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(displayedSongs, id: \.id) { song in
                        let index = displayedSongs.firstIndex(where: { $0.id == song.id }) ?? 0
                        SongItemView(
                            song: song,
                            screenHeight: screenHeight,
                            screenWidth: proxy.size.width,
                            index: index,
                            currentIndex: $currentIndex
                        )
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .coordinateSpace(name: "scroll")
            .scrollPosition(id: $vmBinding.scrollPosition)
        }
        .ignoresSafeArea()
    }
}

struct SongItemView: View {
    
    @Environment(MainReelPlayerViewModel.self) var vm
    //Params
    let song: Song
    let screenHeight: CGFloat
    let screenWidth: CGFloat
    let index: Int
    @Binding var currentIndex: Int
    
    //View props
    @State var player = PlayerService.shared
    //Computed property
    private var isCurrentSong: Bool {
        player.currentTrack?.id == song.id
    }
    
    var body: some View {
        // Background with artwork
        ZStack {
            SmartArtworkView(song: song, size: CGSize(width: screenWidth, height: screenHeight))
                .clipped()
                .blur(radius: 32)
                .overlay(Color.black.opacity(0.4))
                .drawingGroup()
            
            // Content
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text(song.fileNameWithoutExtension)
                    .hSpacing(.leading)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 23))
                    .minimumScaleFactor(0.8)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 8)
                    .lineLimit(4)
                    .frame(maxHeight: 70)
                    .padding(.horizontal)
                    .padding(.bottom, 23)
                
                // Artwork/Thumbnail
                Group {
                    if song.artwork != nil {
                        Image(uiImage: UIImage.fromData(song.artwork))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: screenHeight * 0.4)
                            .clipped()
                            .shadow(radius: 12)
                    } else if song.isVideo {
                        ThumbnailNoWidthView(fileURL: song.fileURL, maximumSize: CGSize(width: 800, height: 800))
                            .frame(height: screenWidth)
                            .frame(maxHeight: screenHeight * 0.4)
                            .clipped()
                            .shadow(radius: 12)
                    } else {
                        Image(.defaultM)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: screenHeight * 0.4)
                            .clipped()
                            .shadow(radius: 12)
                    }
                }
                .clipped()
                .shadow(radius: 12)
                .overlay(
                    VStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.5), .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 40)
                        
                        Spacer()
                        
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, Color.black.opacity(0.5)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 40)
                    }
                )
                .drawingGroup()
                
                // Song Info
                VStack(alignment: .leading, spacing: 12) {
                    Text(song.fileNameWithoutExtension)
                        .font(.system(size: 23))
                        .hSpacing(.leading)
                        .frame(maxHeight: 70)
                        .lineLimit(2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(song.artist.isEmpty ? "Artist: <unknown>" : "Artist: \(song.artist)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(song.albumName.isEmpty ? "Album: unknown" : "Album: \(song.albumName.capitalized)")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 32) {
                    Button {
                        song.isFavorite.toggle()
                    } label: {
                        Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                            .imageScale(.medium)
                            .contentTransition(.symbolEffect(.replace))
                            .foregroundStyle(song.isFavorite ? .red : .primary)
                    }
                    
                    if let songUrl = song.fileURL {
                        ShareLink(item: songUrl) {
                            Image(systemName: "arrowshape.turn.up.right")
                                .imageScale(.medium)
                                .foregroundStyle(.primary)
                        }
                    }
                    
                    Image(systemName: "list.and.film")
                        .imageScale(.medium)
                        .hSpacing(.trailing)
                        .contentShape(.rect)
                        .onTapGesture {
                            Coordinator.shared.presentSheet(
                                SongOptionsSheetView(song: song)
                                    .environment(vm)
                            )
                        }
                }
                .foregroundColor(.white)
                .font(.title3)
                .padding(.horizontal)
                
                Spacer()
                
                // Player Controls
                VStack(spacing: 1) {
                    HStack(spacing: 8) {
                        if isCurrentSong {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundStyle(.white)
                                .font(.caption)
                        }
                        
                        Slider(
                            value: $player.progress,
                            in: 0...1,
                            onEditingChanged: { isEditing in
                                if !isEditing {
                                    let tg = player.progress * player.duration
                                    player.seek(to: tg)
                                }
                            }
                        )
                        .accentColor(.white)
                        
                        if isCurrentSong {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                .foregroundStyle(.white)
                                .font(.caption)
                                .onTapGesture {
                                    player.play(song: song)
                                }
                        }
                    }
                    
                    HStack {
                        Text("\(player.currentTime.formattedTime())")
                        if !isCurrentSong, let currentTrack = player.currentTrack {
                            Text(currentTrack.fileNameWithoutExtension)
                                .lineLimit(1)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                                .hSpacing(.center)
                        } else {
                            Spacer()
                        }
                        Text("\(player.duration.formattedTime())")
                    }
                    .font(.caption)
                    .drawingGroup()
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.horizontal)
                .safeAreaPadding(.bottom, 90)
                .overlay(alignment: .top) {
                    if !isCurrentSong && player.currentTrack != nil {
                        Text("Jump to now playing")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.top, -20)
                    }
                }
                .onTapGesture {
                    withAnimation(.spring) {
                        vm.selectedFilter = .all
                        vm.scrollPosition = player.currentTrack?.id
                    }
                }
            }
            .safeAreaPadding(.top, 65)
        }
        .animation(.spring, value: isCurrentSong)
        .frame(width: screenWidth)
        .containerRelativeFrame(.vertical)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onChange(of: geo.frame(in: .named("scroll")).minY) { _, newValue in
                        if abs(newValue) < screenHeight/2 && currentIndex != index {
                            print("Current song: \(song.fileNameWithoutExtension) at index: \(index)")
                            currentIndex = index
                            player.currentIndex = index
                        }
                    }
            }
        )
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
