//
//  SwiftUIView.swift
//  McNza
//
//  Created by xqsadness on 5/6/25.
//

import SwiftUI
import SwiftData

struct MainReelPlayerView: View {
    @State var player = PlayerService.shared
    @Query(sort: \Song.dateAdd, order: .reverse) var songs: [Song]
    
    var body: some View {
        GeometryReader { proxy in
            let screenHeight = proxy.size.height
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(songs, id: \.self) { song in
                        ZStack {
                            ZStack {
                                SmartArtworkView(song: song, size: CGSize(width: proxy.size.width, height: screenHeight))
                                    .clipped()
                                    .blur(radius: 32)
                                    .overlay(Color.black.opacity(0.4))
                                
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
                                    
                                    Group{
                                        if song.artwork != nil{
                                            Image(uiImage: UIImage.fromData(song.artwork))
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(maxWidth: .infinity, maxHeight: screenHeight * 0.4)
                                                .clipped()
                                                .shadow(radius: 12)
                                        }else if song.isVideo{
                                            ThumbnailNoWidthView(fileURL: song.fileURL, maximumSize: CGSize(width: 800, height: 800))
                                                .frame(height: proxy.size.width)
                                                .frame(maxHeight: screenHeight * 0.4)
                                                .clipped()
                                                .shadow(radius: 12)
                                        }else{
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
                                            // Top blur
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.black.opacity(0.5), .clear]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                            .frame(height: 40)
                                            
                                            Spacer()
                                            // Bottom blur
                                            LinearGradient(
                                                gradient: Gradient(colors: [.clear, Color.black.opacity(0.5)]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                            .frame(height: 40)
                                        }
                                    )
                                    
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
                                        
                                        Text("\(song.albumName.isEmpty ? "Album name: unknown" : "Album name: \(song.albumName.capitalized)")")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 12)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 32) {
                                        Button{
                                            song.isFavorite.toggle()
                                        }label:{
                                            Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                                                .imageScale(.medium)
                                                .contentTransition(.symbolEffect(.replace))
                                                .foregroundStyle(song.isFavorite ? .red : .primary)
                                        }
                                        
                                        if let songUrl = song.fileURL{
                                            ShareLink(item: songUrl){
                                                Image(systemName: "arrowshape.turn.up.right")
                                                    .imageScale(.medium)
                                                    .foregroundStyle(.primary)
                                            }
                                        }
                                        
                                        Image(systemName: "list.and.film")
                                            .imageScale(.medium)
                                            .hSpacing(.trailing)
                                    }
                                    .foregroundColor(.white)
                                    .font(.title3)
                                    .padding(.horizontal)
                                    
                                    Spacer()
                                    
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
                                    .padding(.horizontal)
                                    .safeAreaPadding(.bottom, 90)
                                }
                                .safeAreaPadding(.top, 65)
                            }
                        }
                        .frame(width: proxy.size.width)
                        .containerRelativeFrame(.vertical)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MainReelPlayerView()
}
