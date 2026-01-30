//
//  RatingManager.swift
//  spots
//
//  Created by Aiden Gage on 1/19/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

// codable rating obejct to send to firebase db
struct Rating: Codable {
    var userId: String?
    var postId: String?
    var rating: Decimal?
    var comment: String?
}

// basic rating and comment for now
class RatingMan: Identifiable {
    let userId: String
    let postId: String
    let rating: Decimal
    let comment: String
    
    // need to add things like photos and attaching song
    
    init (userId: String, postId: String, rating: Decimal, comment: String) {
        self.userId = userId
        self.postId = postId
        self.rating = rating
        self.comment = comment
    }
}
