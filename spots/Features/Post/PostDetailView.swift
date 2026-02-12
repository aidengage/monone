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
    
    var body: some View {
        ScrollView {
            VStack {
               
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
                    
                    StarRatingViewStatic(rating: Firebase.shared.post?.avgRating ?? 0.0/*avgRating*/, numStars: 5)
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
            }
        }
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
//    let imageUUIDs: [String]
    @State var images: [UIImage] = []
    @State var urls: [String]
    
    @State var data: [Data] = []
    @State var newImageUUIDs: [String] = []
    
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
//                            Image(systemName: "photo")
                    }
                }
            }
            .frame(height: 300)
        }
//        .onAppear(){
//            Task {
//                getAsyncImageURLs()
//            }
//        }
//        .background(Color(.systemBackground))
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
//        .padding(.horizontal, 20)
    }
    
//    func getAsyncImageURLs() {
//        urls = Firebase.shared.getImageURLs(uuids: imageUUIDs)
//    }
    
//    func getImages() async {
//        do {
//            images = try await Firebase.shared.getImagesByUUID(uuids: imageUUIDs)
//        } catch {
//            print("error loading uuid images")
//        }
//    }
        
}

struct RatingCards: View {
//    let postId: String
//    let postOwner: String
    var ratings: [Rating]
//    @State var ratingsArray: [Rating] = []
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text("user ratings go here...")
                ForEach(ratings) { rating in
//                    CommentCard(rating: rating.rating, user: rating.userId, comment: rating.comment)
                    CommentCard(rating: rating)
                }
            }
        }
//        .onAppear() {
//            Firebase.shared.getPostRatings(postOwner: postOwner, postId: postId) { loadedRatings in
//                DispatchQueue.main.async {
//                    self.ratingsArray = loadedRatings
//                }
//            }
//        }
    }
}

struct CommentCard: View {
    var rating: Rating
//    var rating: Decimal
//    var user: String
//    var comment: String
    
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
