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
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let username: String
    let pfpUrl: String?
}

// not used yet but will be when we get user accounts
struct UserMan {
    let userId: String
    let email: String
    let username: String
    let pfpUrl: String
    
    init(userId: String, email: String, username: String, pfpUrl: String) {
        self.userId = userId
        self.email = email
        self.username = username
        self.pfpUrl = pfpUrl
    }
}
