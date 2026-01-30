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
    
    let store = FireStore()
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
        store.getAllPosts(completion: completion)
    }
    
    func getUserPosts(completion: @escaping ([PostMan]) -> Void) {
        return store.getUserPosts(completion: completion)
    }
    
    func addPost(images: [String], name: String, address: String, rating: Decimal, ratingCount: Int, comment: String, coords: (lat: Double, long: Double), selectedActivity: String) async {
        await store.addPost(images: images, name: name, address: address, rating: rating, ratingCount: ratingCount, comment: comment, coords: (lat: coords.lat, long: coords.long), selectedActivity: selectedActivity)
    }
    
    func addPostIDToUser(postID: String) {
        store.addPostIDToUser(postID: postID)
    }
    
    func getPostRatings(postOwner: String, postId: String, completion: @escaping ([RatingMan]) -> Void) {
        store.getPostRatings(postOwner: postOwner, postId: postId, completion: completion)
    }
    
    func getPostAverageRatings(postId: String) async throws -> Decimal {
        return try await store.getPostAverageRatings(postId: postId)
    }
    
    func addUser(uid: String, email: String, username: String, posts: [String]) {
        store.addUser(uid: uid, email: email, username: username)
    }
    
    func addPostToRated(postID: String) {
        store.addPostToRated(postID: postID)
    }
    
    func addRatingToPost(postOwner: String, postId: String, userId: String, rating: Decimal, comment: String) async {
        await store.addRatingToPost(postOwner: postOwner, postId: postId, userId: userId, rating: rating, comment: comment)
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
