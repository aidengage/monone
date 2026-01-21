//
//  PostDetailView.swift
//  spots
//
//  Created by Minahil on 1/4/26.
//

import SwiftUI

struct PostDetailView: View {
    let post: PostMan
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
               
                VStack {
                    // Title Section
                    // photo card view should display all photos horizontally
                    if !post.images.isEmpty {
                        PhotoCard(imageUUIDs: post.images)
                    }
//                    HStack {
                        VStack(alignment: .leading) {
                            Text(post.userId)
                            Text(post.title)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 10)
    //                    .padding(.top, 20)
                        
                        StarRatingViewStatic(rating: post.rating, numStars: 5)
                        .padding(.horizontal, 20)
//                    }
                    
                    
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
                    
                    // Description Card
                    if !post.description.isEmpty {
                        InfoCard(
                            icon: "text.alignleft",
                            title: "Description",
                            content: post.description,
                            iconColor: .blue
                        )
                    }
                    
                    // Coordinates Card
                    InfoCard(
                        icon: "location.circle.fill",
                        title: "Location",
                        content: String(format: "Lat: %.6f\nLon: %.6f", post.coords.0, post.coords.1),
                        iconColor: .green
                    )
                    
                    if !post.selectedActivity.isEmpty{
                        InfoCard(icon: "text.align.left", title: "Type", content:post.selectedActivity, iconColor: .pink)
                    }
                    
                    
                    RateSpotView(post: post)
                    
                    if !post.docId.isEmpty {
                        Text("comments go here")
//                        CommentCard(postID: post.docId, postOwner: post.userId)
                        UserRatings(postID: post.docId, postOwner: post.userId)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
//        .task {
//            print("uuids: \(post.images)")
//        }
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
    let imageUUIDs: [String]
    @State var images: [UIImage] = []
    @State var urls: [URL] = []
    
    @State var data: [Data] = []
    @State var newImageUUIDs: [String] = []
    
    var body: some View {
        ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(urls, id: \.self) { url in
                        AsyncImage(url: url) { image in
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
//                    VStack {
//                        PhotoSelector(data: $data, imageUUIDs: $newImageUUIDs)
//                    }
                    
                }
                .frame(height: 300)
                
            
            
        }
        .onAppear(){
            Task {
//                await getImages()
                getAsyncImageURLs()
            }
        }
        .background(Color(.systemBackground))
//        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
//        .padding(.horizontal, 20)
    }
    
    func getAsyncImageURLs() {
        urls = FirebaseManager.shared.getImageURLs(uuids: imageUUIDs)
    }
    
    func getImages() async {
        do {
            images = try await FirebaseManager.shared.getImagesByUUID(uuids: imageUUIDs)
        } catch {
            print("error loading uuid images")
        }
    }
        
}

struct UserRatings: View {
    let postID: String
    let postOwner: String
    @State var ratingsArray: [RatingMan] = []
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text("user ratings go here...")
                ForEach(ratingsArray) { rating in
                    CommentCard(rating: rating.rating, user: rating.userID, comment: rating.comment)
                }
            }
        }
        .onAppear() {
            FireIntegration.shared.getPostRatings(postOwner: postOwner, postID: postID) { loadedRatings in
                DispatchQueue.main.async {
                    self.ratingsArray = loadedRatings
                }
            }
        }
    }
}

struct CommentCard: View {

    var rating: Decimal
    var user: String
    var comment: String
    
    var body: some View {
        VStack {
            Text(user)
            StarRatingViewStatic(rating: rating, numStars: 5)
            Text(comment)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
    
    

}
