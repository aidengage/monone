//
//  RatingManager.swift
//  spots
//
//  Created by Aiden Gage on 1/19/26.
//

import SwiftUI

// codable rating obejct to send to firebase db
struct Rating: Codable {
    var user: String?
    var rating: Decimal?
    var comment: String?
}

// basic rating and comment for now
class RatingMan: Identifiable {
    let userID: String
    let rating: Decimal
    let comment: String
    
    // need to add things like photos and attaching song
    
    init (userID: String, rating: Decimal, comment: String) {
        self.userID = userID
        self.rating = rating
        self.comment = comment
    }
}
