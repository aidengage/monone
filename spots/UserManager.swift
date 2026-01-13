//
//  User.swift
//  spots
//
//  Created by Aiden Gage on 1/13/26.
//
import SwiftUI

class UserManager: Identifiable {
    let userID: String
    let email: String
    let username: String
    let posts: [Post]
    
    init(userID: String, email: String, username: String, posts: [Post]) {
        self.userID = userID
        self.email = email
        self.username = username
        self.posts = posts
    }
}
