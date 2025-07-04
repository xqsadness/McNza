//
//  PlaylistView.swift
//  McNza
//
//  Created by xqsadness4 on 5/6/25.
//

import SwiftUI

struct PlaylistView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("Playlist")
                    .font(.title)
                    .fontWeight(.bold)
                    .hSpacing(.leading)
                    .padding(.top, 24)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .foregroundStyle(.white)
                
                // Stats Cards
                HStack(spacing: 16) {
                    PlaylistStatCard(
                        icon: "arrow.down.circle",
                        title: "Downloaded",
                        subtitle: "0 track",
                        color: .purple
                    )
                    PlaylistStatCard(
                        icon: "clock.arrow.circlepath",
                        title: "Recent Play",
                        subtitle: "11 tracks",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 12)

                // My Favorites
                HStack {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.pink.opacity(0.2))
                                .frame(width: 48, height: 48)
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                                .font(.title2)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("My Favorites")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("0 song")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.6))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.bottom, 12)

                // Tabs
                HStack {
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedTab = 0
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text("Created Playlists")
                                .fontWeight(selectedTab == 0 ? .bold : .regular)
                                .foregroundColor(selectedTab == 0 ? .white : .gray)
                            Capsule()
                                .fill(selectedTab == 0 ? Color.blue : Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedTab = 1
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text("Favorite Playlists")
                                .fontWeight(selectedTab == 1 ? .bold : .regular)
                                .foregroundColor(selectedTab == 1 ? .white : .gray)
                            Capsule()
                                .fill(selectedTab == 1 ? Color.blue : Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 16) {
                        if selectedTab == 0 {
                            // Created Playlists
                            PlaylistSectionCard(
                                title: "Created Playlists (0)",
                                icon: "plus",
                                spacing: 12
                            ) {
                                PlaylistActionRow(
                                    icon: "arrow.right.square",
                                    title: "Import External Music",
                                    subtitle: "Create the same playlists with other apps in 1 step",
                                    iconColor: .blue
                                ) {
                                    Coordinator.shared.presentSheet(SheetImport())
                                }

                                PlaylistActionRow(
                                    icon: "plus",
                                    title: "Create playlist",
                                    subtitle: "Create your own playlist",
                                    iconColor: .gray
                                ) {
                                    
                                }
                            }
                        } else {
                            // Favorite Playlists
                            PlaylistSectionCard(
                                title: "Favorite Playlists (0)",
                                icon: nil,
                                spacing: 12
                            ) {
                                VStack(spacing: 12) {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .frame(width: 48, height: 48)
                                        .foregroundColor(.gray)
                                    Text("Not logged in")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Log in to create or save playlists you like")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
                .background(Color.clear)
                
                Spacer(minLength: 0)
            }
        }
    }
}

struct PlaylistStatCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6).opacity(0.6))
        .cornerRadius(16)
    }
}

struct PlaylistSectionCard<Content: View>: View {
    let title: String
    let icon: String?
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color(.systemGray4).opacity(0.3))
                        .clipShape(Circle())
                }
                Image(systemName: "list.bullet")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color(.systemGray4).opacity(0.3))
                    .clipShape(Circle())
            }
            .padding(.bottom, 8)
            
            content()
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.6))
        .cornerRadius(16)
    }
}

struct PlaylistActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.title2)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    PlaylistView()
}
