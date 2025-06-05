//
//  SwiftUIView.swift
//  McNza
//
//  Created by xqsadness on 5/6/25.
//

import SwiftUI

struct SongTemp: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let description: String
    let image: String
    let likes: Int
    let comments: Int
    let shares: Int
}

let tempSongs: [SongTemp] = [
    SongTemp(title: "Khóc Cùng Em", artist: "Mr.Siro, Wind, Gray", description: "Cuộc gọi đến, và như mọi khi", image: "test", likes: 27700, comments: 21, shares: 1),
    SongTemp(title: "Em Gái Mưa", artist: "Hương Tràm", description: "Bản hit đình đám", image: "test2", likes: 15000, comments: 10, shares: 2),
    SongTemp(title: "Có Chàng Trai Viết Lên Cây", artist: "Phan Mạnh Quỳnh", description: "Nhạc phim Mắt Biếc", image: "test", likes: 32000, comments: 30, shares: 5)
]

struct DiscoveryTabView: View {
    var body: some View {
        GeometryReader { proxy in
            let screenHeight = proxy.size.height
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(tempSongs) { song in
                        ZStack {
                            Image(song.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: screenHeight)
                                .clipped()
                                .blur(radius: 32)
                                .overlay(Color.black.opacity(0.45))
                                .ignoresSafeArea()
                            VStack(alignment: .leading, spacing: 0) {
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(song.title)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .shadow(radius: 8)
                                    Text(song.artist)
                                        .font(.title3)
                                        .foregroundColor(.white.opacity(0.85))
                                    Text(song.description)
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.horizontal)
                                
                                Image(song.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: proxy.size.width * 0.7, maxHeight: 220)
                                    .cornerRadius(20)
                                    .shadow(radius: 12)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 32)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 16) {
                                        Text(song.title)
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Button(action: {}) {
                                            Text("Follow")
                                                .font(.subheadline)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 6)
                                                .background(Color.white.opacity(0.15))
                                                .foregroundColor(.white)
                                                .cornerRadius(16)
                                        }
                                    }
                                    Text(song.artist)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.horizontal)
                                
                                Spacer()
                                
                                HStack(spacing: 32) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "heart.fill")
                                        Text("\(song.likes.formatted())")
                                    }
                                    HStack(spacing: 4) {
                                        Image(systemName: "text.bubble")
                                        Text("\(song.comments)")
                                    }
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrowshape.turn.up.right")
                                        Text("\(song.shares)")
                                    }
                                    Image(systemName: "arrow.down.circle")
                                    Image(systemName: "line.3.horizontal")
                                }
                                .foregroundColor(.white)
                                .font(.title3)
                                .padding(.horizontal)
                                
                                VStack(spacing: 8) {
                                    Slider(value: .constant(0.3))
                                        .accentColor(.white)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 80)
                            }
                            .frame(width: proxy.size.width, height: screenHeight, alignment: .center)
                        }
                        .frame(width: proxy.size.width)
                        .containerRelativeFrame(.vertical)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
        }
        .ignoresSafeArea()
    }
}
