//
//  NewPostView.swift
//  spots
//
//  Created by Aiden Gage on 6/7/26.
//

import SwiftUI
import Kingfisher


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
        .onAppear {
            // also start single post listener?
            dbService.startPostListenerById(postId: post.id)
            dbService.startRatingListener(postId: post.id)
//            addTapGestureToDismissKeyboard()
//            bookmarkedPostIds = userService.getBookmarks()
//            followingUserIds = userService.getFollowing()
        }
//        .task(id: post.userId) {
//            owner = await userService.fetchUsername(userId: post.userId) ?? "Unknown user"
//        }
        .onDisappear {
            dbService.stopRatingListener()
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

//#Preview {
//    
//}


// New file: Features/PostViewing/PostFloatingCards.swift

struct PostOverlayCards: View {
    @Environment(\.visible) private var visible
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
            .onAppear {
                visible.update(newState: false)
//                print(visible.currState())
            }
            .onDisappear {
                visible.update(newState: true)
//                print(visible.currState())
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

struct PhotoCardTop: View {
    let urls: [String]  // Array of image URLs

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: .constant(0)) {  // Use @State if you want to track the selected tab
                ForEach(urls.indices, id: \.self) { index in
                    KFImage.url(URL(string: urls[index]))
                        .resizable()
                        .scaledToFill()
//                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct InfoCardBottom: View {
    let icon: String          // Icon name (SF Symbols)
    let title: String         // Title of the info card
    let content: String       // Content to display
    let iconColor: Color      // Color for the icon

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
//                    .textSelectionEnabled()  // Allow text selection for copying
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

