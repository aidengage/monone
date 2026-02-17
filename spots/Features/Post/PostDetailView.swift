//
//  PostDetailView.swift
//  spots
//
//  Created by Minahil on 1/4/26.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    
    @Environment(\.dismiss) private var dismiss
    
    enum DisplayPost {
        case main
        case raw
    }
    
    @State private var displayView: DisplayPost = .main
    
    var body: some View {
        ScrollView {
            VStack {
                
                Picker("post view", selection: $displayView) {
                    Text("Main").tag(DisplayPost.main)
                    Text("Raw").tag(DisplayPost.raw)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if displayView == .main {
                    VStack {
                        // Title Section
                        // photo card view should display all photos horizontally
                        if !post.images.isEmpty {
                            PhotoCard(urls: post.images)
                        }
                        VStack(alignment: .leading) {
                            Text(post.userId)
                            Text(post.name)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 10)
                        
                        if post.userId == Firebase.shared.getCurrentUserID() {
                            Button(action: {
                                Task {
                                    await Firebase.shared.deletePostBatch(postId: post.id)
                                }
                                dismiss()
                            }) {
                                Label("delete post", systemImage: "trash")
                            }
                            .buttonStyle(.glassProminent)
                        }
                        
                        StarRatingViewStatic(rating: Firebase.shared.post?.avgRating ?? 0.0, numStars: 5)
                            .padding(.horizontal, 20)
                        
                        
                        // info cards to represent address, description, and coords
                        // need to add photos and name/title
                        
                        
                        if !post.address.isEmpty {
                            InfoCard(
                                icon: "mappin.circle.fill",
                                title: "Address",
                                content: post.address,
                                iconColor: .red
                            )
                        }
                        
                        // Coordinates Card
                        InfoCard(
                            icon: "location.circle.fill",
                            title: "Location",
                            content: String(format: "Lat: %.6f\nLon: %.6f", post.latitude, post.longitude),
                            iconColor: .green
                        )
                        
                        if !post.selectedActivity.isEmpty{
                            InfoCard(
                                icon: "leaf",
                                title: "Type",
                                content: post.selectedActivity,
                                iconColor: .green
                            )
                        }
                        
                        
                        RateSpotView(post: post)
                        
                        if !post.id.isEmpty {
                            Text("comments go here")
                            RatingCards(ratings: Firebase.shared.ratings)
                        }
                    }
                } else {
                    DebugPostView(post: post)
                }
                
                
            }
        }
//        .introspectScrollView { scrollView in
//                        scrollView.alwaysBounceVertical = false
//                    }
        .onAppear {
            // also start single post listener?
            Firebase.shared.startPostListenerById(postId: post.id)
            Firebase.shared.startRatingListener(postId: post.id)
        }
        .onDisappear {
            Firebase.shared.stopRatingListener()
        }
    }
}

struct DebugPostView: View {
    let post: Post
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                    Text("images[\(post.images.count)]")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    ScrollView {
                        HStack {
                            ForEach(post.images.indices, id: \.self) { index in
                                VStack {
                                    AsyncImage(url: URL(string: post.images[index])) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Rectangle()
                                            .overlay(ProgressView())
                                    }
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    
                                    Text("[\(index)]")
                                        .font(.system(.caption2, design: .monospaced))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                .padding(.vertical)
                
                Group {
                    dataRow(key: "id", value: post.id)
                    dataRow(key: "userId", value: post.userId)
                    dataRow(key: "name", value: post.name)
                    dataRow(key: "address", value: post.address)
                    dataRow(key: "latitude", value: String(format: "%.6f", post.latitude))
                    dataRow(key: "longitude", value: String(format: "%.6f", post.longitude))
                    dataRow(key: "avgRating", value: "\(post.avgRating)")
                    dataRow(key: "ratingCount", value: "\(post.ratingCount)")
                    dataRow(key: "selectedActivity", value: post.selectedActivity)
                    VStack(alignment: .leading) {
                        ForEach(post.images.indices, id: \.self) { index in
                            dataRow(key: "image\(index+1)", value:post.images[index])
                        }
                    }
                }
            }
        }
    }
    
    private func dataRow(key: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(key)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.blue)
            
            Text(":")
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }
}

// info card template used for each individual aspect of the post
struct InfoCard: View {
    let icon: String
    let title: String
    let content: String
    let iconColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

struct PhotoCard: View {
    @State var urls: [String]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(urls, id: \.self) { url in
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                    } placeholder: {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                }
            }
            .frame(height: 300)
        }
    }
}

struct RatingCards: View {
    var ratings: [Rating]
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text("user ratings go here...")
                ForEach(ratings) { rating in
                    CommentCard(rating: rating)
                }
            }
        }
    }
}

struct CommentCard: View {
    var rating: Rating
    
    var body: some View {
        VStack {
            Text(rating.userId)
            if rating.userId == Firebase.shared.getCurrentUserID() {
                Button(action: {
                    Task {
                        await Firebase.shared.removeRatingFromPost(postId: rating.postId)
                    }
                }) {
                    Label("delete rating", systemImage: "trash")
                }
                .buttonStyle(.glassProminent)
            }
            StarRatingViewStatic(rating: rating.rating, numStars: 5)
            Text(rating.comment)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}
