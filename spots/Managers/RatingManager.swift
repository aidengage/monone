//
//  RatingManager.swift
//  spots
//
//  Created by Aiden Gage on 1/19/26.
//

import SwiftUI

// basic rating and comment for now
class RatingMan: Identifiable {
    let user: String
    let rating: Decimal
    let comment: String
    
    // need to add things like photos and attaching song
    
    init (user: String, rating: Decimal, comment: String) {
        self.user = user
        self.rating = rating
        self.comment = comment
    }
}
