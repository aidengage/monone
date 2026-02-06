//
//  PostMan.swift
//  spots
//
//  Created by Aiden Gage on 1/4/26.
//

import SwiftUI
import MapKit
import FirebaseCore
import FirebaseFirestore

// post manager service/class file to represent a post obejct
// need to change image to something like an array of [images] to link them to posts
// still need to rework database for users/posts

// codable user obejct to send to firebase database
struct Post: Codable, Identifiable {
    let id: String
    let userId: String
    let images: [String]
    let name: String
    let address: String
    let ratingCount: Int
    let latitude: Double
    let longitude: Double
    let avgRating: Decimal
    let selectedActivity: String
//    let createdAt: Date?
//    let updatedAt: Date?
}


extension Firebase {

    func addPost(images: [String], name: String, address: String, rating: Decimal, ratingCount: Int, comment: String, coords: (lat: Double, long: Double), selectedActivity: String) async {
        let postId = UUID().uuidString
        
        let newPost = Post(id: postId, userId: getCurrentUserID(), images: images, name: name, address: address, ratingCount: ratingCount, latitude: coords.lat, longitude: coords.long, avgRating: rating, selectedActivity: selectedActivity)
        
        let newRating = Rating(id: UUID().uuidString, userId: getCurrentUserID(), postId: postId, rating: rating, comment: comment)
        
        do {
            // adding post to posts collection
            let postRef = getStore().collection("posts").document(postId)
            try postRef.setData(from: newPost) { error in
                if let error = error {
                    print(error)
                } else {
                    postRef.updateData(["createdAt": FieldValue.serverTimestamp()])
                    print("doc added")
                }
            }
            
            // basically checks if the user actively rated the spot on creation or not
            if newRating.comment != "" {
                // adding rating to ratings collection
                let ratingRef = getStore().collection("ratings").document(newRating.id)
                
                try ratingRef.setData(from: newRating) { error in
                    
                    if let error = error {
                        print("error adding rating: \(error)")
                    } else {
                        ratingRef.updateData(["createdAt": FieldValue.serverTimestamp()])
                        print("rating added??")
                    }
                }
            }
            
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
    }
    
    func deletePost(postId: String) async {
        do {
            let batch = getStore().batch()
            batch.deleteDocument(getStore().collection("posts").document(postId))
            try await batch.commit()
        } catch {
            print("error deleting post: \(error.localizedDescription)")
        }
    }
    
    func deletePostBatch(postId: String) async {
        await deleteRatingsOfPost(postId: postId/*, userId: getCurrentUserID()*/)
        await deletePost(postId: postId)
        
//        getStore().collection("posts").document(postId).delete() { error in
//            if let error = error {
//                print("error deleting post: \(error)")
//            } else {
//                print("deleted post!")
//            }
//        }
        
    }
    
    func startPostListener() {
        stopPostListener()
        
        postListener = getStore().collection("posts").addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting posts: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No posts found")
                self.posts = []
                return
            }
            
            print("inside postlistener: \(documents.count)")
            
            self.posts = documents.compactMap { document in
                do {
                    let post = try document.data(as: Post.self)
//                    print(post)
                    return post
                } catch {
                    print("Error decoding document \(document.documentID): \(error)")
                    return nil
                }
            }
        }
        print("post class listerner count: \(self.posts.count)")
    }
    
    func stopPostListener() {
        postListener?.remove()
        postListener = nil
    }
}
