//
//  FireDB.swift
//  spots
//
//  Created by Aiden Gage on 1/20/26.
//

import SwiftUI
import FirebaseCore
import FirebaseStorage
import FirebaseAuth

final class Firebase {
    static let shared = Firebase()
    
    private let fs = FireStore()
    private let auth = FireAuth()
    private let storage = FireStorage()
    
    // function proxies to separate out firebase implementation
    func getStorage() -> Storage {
        return storage.getStorage()
    }
    
    func getCurrentUserID() -> String {
        return auth.getCurrentUserID()
    }
    
    func getCurrentUser() -> FirebaseAuth.User? {
        return auth.getCurrentUser()
    }
    
    func logout() {
        auth.logout()
    }
    
    func getAllPosts(completion: @escaping ([PostMan]) -> Void) {
        fs.getAllPosts(completion: completion)
    }
    
    func getUserPosts(completion: @escaping ([PostMan]) -> Void) {
        return fs.getUserPosts(completion: completion)
    }
    
    func addPost(images: [String], name: String, address: String, rating: Decimal, comment: String, coords: (xLoc: Double, yLoc: Double), selectedActivity: String) {
        fs.addPost(images: images, name: name, address: address, rating: rating, comment: comment, coords: (xLoc: coords.xLoc, yLoc: coords.yLoc), selectedActivity: selectedActivity)
    }
    
    func addPostIDToUser(postID: String) {
        fs.addPostIDToUser(postID: postID)
    }
    
    func getPostRatings(postOwner: String, postID: String, completion: @escaping ([RatingMan]) -> Void) {
        fs.getPostRatings(postOwner: postOwner, postID: postID, completion: completion)
    }
    
    func getPostAverageRatings(postOwner: String, postID: String) async throws -> Decimal {
        return try await fs.getPostAverageRatings(postOwner: postOwner, postID: postID)
    }
    
    func addUser(uid: String, email: String, username: String, posts: [String]) {
        fs.addUser(uid: uid, email: email, username: username, posts: posts)
    }
    
    func addPostToRated(postID: String) {
        fs.addPostToRated(postID: postID)
    }
    
    func addRatingToPost(postOwner: String, postID: String, userID: String, rating: Decimal, comment: String) async {
        await fs.addRatingToPost(postOwner: postOwner, postID: postID, userID: userID, rating: rating, comment: comment)
    }
    
    func uploadImage(uuidArray: [String], data: [Data]) async throws {
        try await storage.uploadImage(uuidArray: uuidArray, data: data)
    }
    
    func getImagesByUUID(uuids: [String]) async throws -> [UIImage] {
        try await storage.getImagesByUUID(uuids: uuids)
    }
    
    func getImageURLs(uuids: [String]) -> [URL] {
        storage.getImageURLs(uuids: uuids)
    }
    
    func getFileSize(ref: StorageReference) async throws -> Int64 {
        try await storage.getFileSize(ref: ref)
    }
    
    func downloadData(ref: StorageReference, size: Int64) async throws -> Data {
        try await storage.downloadData(ref: ref, size: size)
    }

}
