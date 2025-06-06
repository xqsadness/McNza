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
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Account")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                Button(action: {}) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 24)
            .padding(.horizontal)
            .padding(.bottom, 8)

            // 2 nút lớn
            HStack(spacing: 16) {
                PlaylistStatCard(icon: "arrow.down.circle", title: "Downloaded", subtitle: "0 track")
                PlaylistStatCard(icon: "clock.arrow.circlepath", title: "Recent Play", subtitle: "11 tracks")
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            // My Favorites
            HStack {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.pink.opacity(0.2))
                            .frame(width: 48, height: 48)
                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    VStack(alignment: .leading) {
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
            .background(Color(.secondarySystemBackground).opacity(0.5))
            .cornerRadius(18)
            .padding(.horizontal)
            .padding(.bottom, 8)

            // Tabs
            HStack {
                Button(action: { selectedTab = 0 }) {
                    VStack {
                        Text("Created Playlists")
                            .fontWeight(selectedTab == 0 ? .bold : .regular)
                            .foregroundColor(selectedTab == 0 ? .white : .gray)
                        if selectedTab == 0 {
                            Capsule()
                                .fill(Color.blue)
                                .frame(height: 3)
                        } else {
                            Capsule()
                                .fill(Color.clear)
                                .frame(height: 3)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                Button(action: { selectedTab = 1 }) {
                    VStack {
                        Text("Favorite Playlists")
                            .fontWeight(selectedTab == 1 ? .bold : .regular)
                            .foregroundColor(selectedTab == 1 ? .white : .gray)
                        if selectedTab == 1 {
                            Capsule()
                                .fill(Color.blue)
                                .frame(height: 3)
                        } else {
                            Capsule()
                                .fill(Color.clear)
                                .frame(height: 3)
                        }
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
                            content: {
                                PlaylistActionRow(icon: "arrow.right.square", title: "Import External Music", subtitle: "Create the same playlists with other apps in 1 step", iconColor: .blue)
                                    .onTapGesture {
                                        Coordinator.shared.presentSheet(SheetImport())
                                    }
                                
                                PlaylistActionRow(icon: "plus", title: "Create playlist", subtitle: "Create your own playlist", iconColor: .gray)
                            }
                        )
                    } else {
                        // Favorite Playlists
                        PlaylistSectionCard(
                            title: "Favorite Playlists (0)",
                            icon: nil,
                            content: {
                                VStack(spacing: 8) {
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
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 100) // Để chừa chỗ cho mini player/tab bar
            }
            .background(Color.clear)
            
            Spacer(minLength: 0)
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Subviews

struct PlaylistStatCard: View {
    let icon: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground).opacity(0.5))
        .cornerRadius(16)
    }
}

struct PlaylistSectionCard<Content: View>: View {
    let title: String
    let icon: String?
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color(.systemGray4).opacity(0.2))
                        .clipShape(Circle())
                }
                Image(systemName: "list.bullet")
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color(.systemGray4).opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(.bottom, 8)
            content()
        }
        .padding()
        .background(Color(.secondarySystemBackground).opacity(0.5))
        .cornerRadius(18)
    }
}

struct PlaylistActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title2)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.body)
                Text(subtitle)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.caption2)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    PlaylistView()
}
