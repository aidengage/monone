//
//  User.swift
//  spots
//
//  Created by Aiden Gage on 1/13/26.
//
import SwiftUI
import FirebaseCore
import FirebaseFirestore

// codable user obejct to send to firebase database
struct User: Codable {
    var uid: String?
    var email: String?
    var username: String?
//    @ServerTimestamp var createdAt: Timestamp?
//    var posts: [String?]
//    var ratedPosts: [String?]
}

// not used yet but will be when we get user accounts
class UserMan: Identifiable {
    let userID: String
    let email: String
    let username: String
//    let createdAt: Timestamp
//    let posts: [Post]
//    let ratedPosts: [String]
    
    init(userID: String, email: String, username: String/*, posts: [Post]*/) {
        self.userID = userID
        self.email = email
        self.username = username
//        self.createdAt = serverTimestamp()
//        self.posts = posts
//        self.ratedPosts = []
    }
}
