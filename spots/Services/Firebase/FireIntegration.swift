//
//  FireDB.swift
//  spots
//
//  Created by Aiden Gage on 1/20/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

final class FireIntegration {
    static let shared = FireIntegration()
    
    private let fs = FireStore()
    private let auth = FireAuth()
    private let storage = FireStorage()
    
    // function proxies to separate out firebase implementation
    func getCurrentUserID() -> String {
        return auth.getCurrentUserID()
    }
    
    func getAllPostsDocs() -> [String:Any] {
        return fs.getAllPostsDocs()
    }
    
    func getAllPosts(completion: @escaping ([PostMan]) -> Void) {
        fs.getAllPosts(completion: completion)
    }
    
    func getUserPosts() -> [String:Any] {
        return fs.getUserPosts()
    }
    
    func addPost(images: [String], name: String, address: String, rating: Decimal, description: String, coords: (xLoc: Double, yLoc: Double), selectedActivity: String) {
        fs.addPost(images: images, name: name, address: address, rating: rating, description: description, coords: (xLoc: coords.xLoc, yLoc: coords.yLoc), selectedActivity: selectedActivity)
    }
    
    func addPostIDToUser(postID: String) {
        fs.addPostIDToUser(postID: postID)
    }
    
    func getPostRatings(postOwner: String, postID: String, completion: @escaping ([RatingMan]) -> Void) {
        fs.getPostRatings(postOwner: postOwner, postID: postID, completion: completion)
    }
    
    func addUser(uid: String, email: String, username: String, posts: [String]) {
        fs.addUser(uid: uid, email: email, username: username, posts: posts)
    }

}
