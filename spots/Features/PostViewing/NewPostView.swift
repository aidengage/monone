//
//  NewPostView.swift
//  spots
//
//  Created by Aiden Gage on 6/7/26.
//

import SwiftUI

//struct PostView: View {
//    @Environment(\.dismiss) private var dismiss
//    
//    //    @Environment(\.currentUser) private var currentUser
//    //
//    //    @Environment(\.db) private var dbService
//    //    @Environment(\.auth) private var authService
//    //    @Environment(\.storage) private var storageService
//    //    @Environment(\.post) private var postService
//    //    @Environment(\.rating) private var ratingService
//    //    @Environment(\.user) private var userService
//    
//    let post: Post
//    @State private var isPresented = true
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                // Top photo section using your PhotoCardTop component
//                TopSheetView(post: post, isPresented: $isPresented)
//                //                    .frame(height: UIScreen.main.bounds.height * 0.4)
//                    .containerRelativeFrame(.vertical) { length, axis in
//                        length * 0.4
//                    }
//                
//                // Bottom info section reusing your existing InfoCardBottom components
//                BottomSheetView(post: post/*, isPresented: $isPresented*/)
//                    .navigationTitle(post.name)
//                    .navigationBarTitleDisplayMode(.inline)
//                    .toolbar {
//                        ToolbarItem(placement: .topBarTrailing) {
//                            Button(action: { dismiss() }) {
//                                Image(systemName: "xmark")
//                                    .foregroundColor(.primary)
//                            }
//                        }
//                    }
//            }
//        }
//    }
//}

struct TopSheetView: View {
    let post: Post
    @Binding var isPresented: Bool
    
    var body: some View {
        PhotoCardTop(urls: post.images)
    }
}

struct BottomSheetView: View {
    @Environment(\.db) private var dbService
    @Environment(\.currentUser) private var currentUser
    @Environment(\.post) private var postService
    @Environment(\.rating) private var ratingService
    
    let post: Post
//    @Binding var isPresented: Bool
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16) {    
                
                StarRatingViewStatic(rating: dbService.getPost()?.avgRating ?? 0.0, numStars: 5)
                
                InfoCard(
                    icon: "mappin.circle.fill",
                    title: "Address",
                    content: post.address,
                    iconColor: .red
                )
                
                InfoCard(
                    icon: "location.circle.fill",
                    title: "Location",
                    content: String(format: "Lat: %.6f\nLon: %.6f", post.latitude, post.longitude),
                    iconColor: .green
                )
                
                if post.userId == currentUser.uid {
                    EditActivityCard(post: post, PostService: postService)
                } else {
                    InfoCard(
                        icon: "leaf",
                        title: "Type",
                        content: post.selectedActivity,
                        iconColor: .green
                    )
                }
                
                RateSpotView(post: post)
                
                RatingCards(ratings: dbService.getRatings(), RatingService: ratingService)
            }
            .padding()
        }
    }
}

//#Preview {
//    
//}


// New file: Features/PostViewing/PostFloatingCards.swift

struct PostOverlayCards: View {
    let post: Post
    @Binding var isPresented: Bool
    let mapHeight: CGFloat
    let mapWidth: CGFloat

    // Calculate positions based on map size
    private var photoCardPosition: CGPoint {
        CGPoint(x: mapWidth / 2,
                y: mapHeight * 0.17) // % from top
    }
    
//    private var photoCardHeight: CGFloat {
//        
//    }

    private var infoCardsPosition: CGPoint {
        CGPoint(x: mapWidth / 2,
                y: mapHeight * 0.3) // % from top
    }

    var body: some View {
        ZStack {
            // Dismissal background overlay
            Color.black.opacity(0.15)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack {
                // Photo card - positioned above center
                PhotoCardTop(urls: post.images)
                    .frame(width: 350, height: 350)
                    .background(Color(.systemBackground))
                    .cornerRadius(45)
                    .shadow(radius: 45)
                    .position(photoCardPosition)

                // Info cards - positioned below center
                BottomSheetView(post: post)
                    .frame(width: 350, height: 300)
                    .background(Color(.systemBackground))
                    .cornerRadius(45)
                    .shadow(radius: 45)
                    .position(infoCardsPosition)
            }
        }
    }

    private struct BottomInfoCards: View {
        let post: Post

        var body: some View {
            VStack(spacing: 12) {
                Text(post.name)
                    .font(.title3.bold())
                    .padding(.vertical, 8)

                StarRatingViewStatic(rating: post.avgRating, numStars: 5)

                InfoCardBottom(
                    icon: "mappin.circle.fill",
                    title: "Address",
                    content: post.address,
                    iconColor: .red
                )

                InfoCardBottom(
                    icon: "location.circle.fill",
                    title: "Location",
                    content: String(format: "%.6f, %.6f", post.latitude, post.longitude),
                    iconColor: .green
                )

                // Add other info cards as needed...

//                Spacer().frame(height: 20)
            }
            .padding()
        }
    }
}
