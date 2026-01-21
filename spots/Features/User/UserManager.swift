//
//  User.swift
//  spots
//
//  Created by Aiden Gage on 1/13/26.
//
import SwiftUI

// not used yet but will be when we get user accounts
class UserMan: Identifiable {
    let userID: String
    let email: String
    let username: String
    let posts: [Post]
    let ratedPosts: [String]
    
    init(userID: String, email: String, username: String, posts: [Post]) {
        self.userID = userID
        self.email = email
        self.username = username
        self.posts = posts
        self.ratedPosts = []
    }
}
