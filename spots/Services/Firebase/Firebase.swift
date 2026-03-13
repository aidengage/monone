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

@Observable
final class Firebase {
    static let shared = Firebase()
    
    private let store = Firestore.firestore()
    private let auth = Auth.auth()
    let storage = FireStorage()
    
    var posts: [Post] = []
    var postListener: ListenerRegistration?
    var post: Post? /*= Post()*/ // broke
    var ratings: [Rating] = []
    var ratingListener: ListenerRegistration?
    var feedbacks: [Feedback] = []
    var feedbackListener: ListenerRegistration?
    // Current user's bookmarked post IDs (loaded from user doc)
    var bookmarkedPostIds: [String] = []
    private init() {}
    
    enum ImageFormat {
        case jpeg(compressionQuality: CGFloat)
        case png
        case heic
        
        var fileExtension: String {
            switch self {
            case .jpeg: return ".jpg"
            case .png: return ".png"
            case .heic: return ".heic"
            }
        }
        
        var mimeType: String {
            switch self {
            case .jpeg: return "image/jpeg"
            case .png: return "image/png"
            case .heic: return "image/heic"
            }
        }
    }
    
    func getStore() -> Firestore {
        return store
    }
    
    func getAuth() -> Auth {
        return auth
    }
    
    func getStorage() -> Storage {
        return storage.getStorage()
    }
    
    
        
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

    // bookmarks (single list of post IDs on user doc)
    func loadBookmarks() {
        let uid = getCurrentUserID()
        if uid.isEmpty {
            return
        }
        else{
        getStore().collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("error loading bookmarks: \(error)")
                return
            }
            //snapshot fetches the raw json so this takes the raw json and converts it to a user object in Swift 
            if let user = try? snapshot?.data(as: User.self) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    //taking the bookmarks from Firestore and copying them here into our global var so our app can use it locally 
                    self.bookmarkedPostIds = user.bookmarkedPostIds
                }
            }
        }
        }
    }

    func updateBookmarkedPostIds(_ ids: [String]) {
        let uid = getCurrentUserID()
        if uid.isEmpty {
            return
        }
        else{
        getStore().collection("users").document(uid).updateData(["bookmarkedPostIds": ids]) { [weak self] error in
            if let error = error {
                print("error updating bookmarks: \(error)")
                return
            }
            DispatchQueue.main.async {
                self?.bookmarkedPostIds = ids
            }
        }
        }
    }
}
