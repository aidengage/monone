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
import FirebaseFirestore

final class Firebase {
    static let shared = Firebase()
    
    private let store = Firestore.firestore()
    private let auth = Auth.auth()
    private let storage = FireStorage()
    
    func getStore() -> Firestore {
        return store
    }
    
    func getAuth() -> Auth {
        return auth
    }
    
    // function proxies to separate out firebase implementation
    // storage
    func getStorage() -> Storage {
        return storage.getStorage()
    }
    
    // user
//    func getCurrentUserID() -> String {
//        return auth.getCurrentUserID()
//    }
    
    // user
//    func getCurrentUser() -> FirebaseAuth.User? {
//        return auth.getCurrentUser()
//    }
    
    // user
//    func logout() {
//        auth.logout()
//    }
    // post
//    func getAllPosts(completion: @escaping ([PostMan]) -> Void) {
//        store.getAllPosts(completion: completion)
//    }
    
    // post (dont really need this, can query easily
//    func getUserPosts(completion: @escaping ([PostMan]) -> Void) {
//        return store.getUserPosts(completion: completion)
//    }
    
    //post
//    func addPost(images: [String], name: String, address: String, rating: Decimal, ratingCount: Int, comment: String, coords: (lat: Double, long: Double), selectedActivity: String) async {
//        await store.addPost(images: images, name: name, address: address, rating: rating, ratingCount: ratingCount, comment: comment, coords: (lat: coords.lat, long: coords.long), selectedActivity: selectedActivity)
//    }
    
    // post (dont need anymore)
//    func addPostIDToUser(postID: String) {
//        store.addPostIDToUser(postID: postID)
//    }
    
    // rating
//    func getPostRatings(postOwner: String, postId: String, completion: @escaping ([Rating]) -> Void) {
//        store.getPostRatings(postOwner: postOwner, postId: postId, completion: completion)
//    }
    
    // rating
//    func getPostAverageRatings(postId: String) async throws -> Decimal {
//        return try await store.getPostAverageRatings(postId: postId)
//    }
    
    // user
//    func addUser(uid: String, email: String, username: String, posts: [String]) {
//        store.addUser(uid: uid, email: email, username: username)
//    }
    
    // rating (dont need anymore dont think)
//    func addPostToRated(postID: String) {
//        store.addPostToRated(postID: postID)
//    }
    
    // rating
//    func addRatingToPost(postOwner: String, postId: String, userId: String, rating: Decimal, comment: String) async {
//        await store.addRatingToPost(postOwner: postOwner, postId: postId, userId: userId, rating: rating, comment: comment)
//    }
    
    // storage
    func uploadImage(uuidArray: [String], data: [Data]) async throws {
        try await storage.uploadImage(uuidArray: uuidArray, data: data)
    }
    
    // storage
    func getImagesByUUID(uuids: [String]) async throws -> [UIImage] {
        try await storage.getImagesByUUID(uuids: uuids)
    }
    
    // storage
    func getImageURLs(uuids: [String]) -> [URL] {
        storage.getImageURLs(uuids: uuids)
    }
    
    // storage
    func getFileSize(ref: StorageReference) async throws -> Int64 {
        try await storage.getFileSize(ref: ref)
    }
    
    // storage
    func downloadData(ref: StorageReference, size: Int64) async throws -> Data {
        try await storage.downloadData(ref: ref, size: size)
    }

}
