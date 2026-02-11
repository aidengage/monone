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
import FirebaseStorage

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
    
    init(id: String, userId: String, images: [String], name: String, address: String, ratingCount: Int, latitude: Double, longitude: Double, avgRating: Decimal, selectedActivity: String) {
        self.id = id
        self.userId = userId
        self.images = images
        self.name = name
        self.address = address
        self.ratingCount = ratingCount
        self.latitude = latitude
        self.longitude = longitude
        self.avgRating = avgRating
        self.selectedActivity = selectedActivity
    }
    
    init() {
        self.id = "Post ID loading..."
        self.userId = "User ID loading..."
        self.images = []
        self.name = "Name loading..."
        self.address = "Address loading..."
        self.ratingCount = 0
        self.latitude = 0
        self.longitude = 0
        self.avgRating = 0
        self.selectedActivity = "Activity loading..."
    }
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
            print("creating doc: \(error.localizedDescription)")
        }
    }
    
    func deletePost(postId: String) async {
        do {
            let batch = getStore().batch()
            batch.deleteDocument(getStore().collection("posts").document(postId))
            try await batch.commit()
//            startPostListener()
        } catch {
            print("deleting post: \(error.localizedDescription)")
        }
    }
    
    func deletePostBatch(postId: String) async {
        await deleteRatingsOfPost(postId: postId)
        await deleteImagesByUUID(postId: postId)
        await deletePost(postId: postId)
    }
    
    func deleteImagesByUUID(postId: String) async {
        do {
            let imageUUIDs: [String] = try await getStore().collection("posts").document(postId).getDocument()["images"] as? [String] ?? []
    //        let imageUUIDs: [String] = postDoc["images"] as? [String] ?? []
            
            for uuid in imageUUIDs {
                let imageRef = storage.storage.reference().child(uuid)
                try await imageRef.delete()
            }
        } catch {
            print("deleting images: \(error.localizedDescription)")
        }
        
    }
    
//    func startPostListenerById(postId: String) {
//        Firebase.shared.stopPostListener()
//        
//        postListener = Firebase.shared.getStore().collection("posts")
//            .whereField("postId", isEqualTo: postId)
//            .addSnapshotListener { [weak self] (snapshot, error) in
//            guard let self = self else { return }
//            
//            if let error = error {
//                print("Error getting post: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let documents = snapshot?.documents else {
//                print("No post found")
//                self.posts = []
//                return
//            }
//            
//            self.posts = documents.compactMap { document in
//                do {
//                    let post = try document.data(as: Post.self)
////                    print(post)
//                    return post
//                } catch {
//                    print("Error decoding document \(document.documentID): \(error)")
//                    return nil
//                }
//            }
//        }
//    }
    func startPostListenerById(postId: String) {
        Firebase.shared.stopPostListener()

        Firebase.shared.postListener = Firebase.shared.getStore().collection("posts").document(postId).addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error getting post: \(error.localizedDescription)")
                return
            }

            guard let document = snapshot else {
                print("No post found")
                return
            }

            do {
                self.post = try document.data(as: Post.self)
            } catch {
                print("error decoding post (\(postId)): \(error.localizedDescription)")
                print("because it was deleted")
                startPostListener()
            }
        }
//        print("starting single post listener")
    }
    
    func startUserPostListener(userId: String) {
        stopPostListener()
        
        postListener = getStore().collection("posts").whereField("userId", isEqualTo: userId).addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting posts: \(error)")
                return
            }
                
            guard let documents = snapshot?.documents else {
                print("no user posts found")
                self.posts = []
                return
            }
                
            self.posts = documents.compactMap { document in
                do {
                    let post = try document.data(as: Post.self)
                    return post
                } catch {
                    print("error finding user (\(userId) documents: \(error)")
                    return nil
                }
            }
        }
//        print("starting user post listener")
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
            
//            print("inside postlistener: \(documents.count)")
            
            self.posts = documents.compactMap { document in
                do {
                    let post = try document.data(as: Post.self)
                    return post
                } catch {
                    print("Error decoding document \(document.documentID): \(error)")
                    return nil
                }
            }
        }
//        print("starting post listener")
//        print("post class listerner count: \(self.posts.count)")
    }
    
    func stopPostListener() {
        postListener?.remove()
        postListener = nil
    }
}
