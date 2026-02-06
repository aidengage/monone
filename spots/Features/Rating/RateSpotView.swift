//
//  RatingsView.swift
//  spots
//
//  Created by Aiden Gage on 1/19/26.
//
import SwiftUI

struct RateSpotView: View {
    let post: Post
    @State var rating: Decimal = 0
    @State var comment: String = ""
    
    var body: some View {
        VStack( spacing: 16) {
            HStack {
                StarRatingViewDynamic(rating: $rating, numStars: 5)
                Button(action: {
                    Task {
                        if Firebase.shared.getCurrentUserID() != "" {
                            await Firebase.shared.addRatingToPost(postOwner: post.userId, postId: post.id, userId: Firebase.shared.getCurrentUserID(), rating: rating, comment: comment)
                        } else {
                            print("please login")
                        }
                    }
                    
                    
                }) {
                    Label("Rate Spot!", systemImage: "heart.fill")
                        .buttonStyle(.glassProminent)
                }
            }
            TextField("Comment here...", text: $comment, axis: .vertical)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}
