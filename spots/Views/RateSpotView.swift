//
//  RatingsView.swift
//  spots
//
//  Created by Aiden Gage on 1/19/26.
//
import SwiftUI

struct RateSpotView: View {
    let post: PostMan
    @State var rating: Decimal = 0
    @State var comment: String = ""
    
    var body: some View {
        VStack( spacing: 16) {
            StarRatingViewDynamic(rating: $rating, numStars: 5)
            TextField("Comment here...", text: $comment, axis: .vertical)
            Button(action: {
                FirebaseManager.shared.addRatingToPost(postID: post.docId, userID: FirebaseManager.shared.getCurrentUserID(), rating: rating, comment: comment)
            }) {
                Label("Rate Spot!", systemImage: "arrow.2.circlepath.circle")
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}
