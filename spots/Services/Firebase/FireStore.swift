//
//  FireStore.swift
//  spots
//
//  Created by Aiden Gage on 1/21/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

final class FireStore {
    let fs = Firestore.firestore()
    
    func getAllPosts(completion: @escaping ([PostMan]) -> Void) {
        fs.collection("posts").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                completion([])
                return
            }
            
            let posts = documents.compactMap { documents -> PostMan? in
                let data = documents.data()
                
                guard let lat = data["latitude"] as? Double,
                      let long = data["longitude"] as? Double else {
                    print("missing lat/long for post: \(documents.documentID)")
                    return nil
                }
                
                let coords = (lat, long)
                
                var ratingValue: Decimal
                if let avgRating = data["averageRating"] as? Double {
                    ratingValue = Decimal(avgRating)
                } else if let avgRating = data["avgRating"] as? Double {
                    ratingValue = Decimal(avgRating)
                } else {
                    ratingValue = 0
                }
                
                return PostMan(docId: documents.documentID,
                               userId: data["userId"] as? String ?? "",
                               title: data["name"] as? String ?? "",
                               images: data["images"] as? [String] ?? [],
                               coords: coords,
                               address: data["address"] as? String ?? "",
                               rating: ratingValue,
                               selectedActivity: data["selectedActivity"] as? String ?? ""
                )
            }
            completion(posts)
        }
    }
    
    func getUserPosts(completion: @escaping ([PostMan]) -> Void) {
        fs.collection("posts")
            .whereField("userId", isEqualTo: Firebase.shared.getCurrentUserID()).getDocuments() { (querySnapshot, error) in
                
            guard let documents = querySnapshot?.documents else {
                completion([])
                return
            }
            let posts = documents.compactMap { documents -> PostMan? in
                let data = documents.data()
                return PostMan(docId: documents.documentID,
                               userId: data["userID"] as? String ?? "",
                               title: data["name"] as? String ?? "",
//                               comment: data["comment"] as? String ?? "",
                               images: data["images"] as? [String] ?? [],
                               coords: (data["latitude"] as! Double, data["longitude"] as! Double),
                               address: data["address"] as? String ?? "",
                               rating: Decimal.init(data["rating"] as! Double),
                               selectedActivity: data["selectedActivity"] as? String ?? ""
                )
            }
            completion(posts)
        }
    }
    
    func addPost(images: [String], name: String, address: String, rating: Decimal, ratingCount: Int, comment: String, coords: (lat: Double, long: Double), selectedActivity: String) async {
        let postId = UUID().uuidString
        
        let newPost = Post(images: images, name: name, address: address, ratingCount: ratingCount, latitude: coords.lat, longitude: coords.long, /*ratings: [],*/ userId: Firebase.shared.getCurrentUserID(), selectedActivity: selectedActivity)
        
        let newRating = Rating(userId: Firebase.shared.getCurrentUserID(), postId: postId, rating: rating, comment: comment)
        
        do {
            // adding post to posts collection
            let postRef = fs.collection("posts").document(postId)
            try postRef.setData(from: newPost) { error in
                if let error = error {
                    print(error)
                } else {
//                    self.addPostIDToUser(postID: postRef.documentID)
                    postRef.updateData(["createdAt": FieldValue.serverTimestamp()])
                    print("doc added")
                }
            }
            
            // adding rating to ratings collection
            let ratingRef = fs.collection("ratings").document()
            
            try ratingRef.setData(from: newRating) { error in
                
                if let error = error {
                    print(error)
                } else {
                    ratingRef.updateData(["createdAt": FieldValue.serverTimestamp()])
                    print("rating added??")
                }
            }
            let avgRating = try await getPostAverageRatings(postId: postId)
            try await postRef.updateData(["avgRating": avgRating])
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
    }
    
    func addPostIDToUser(postID: String) {
        let uid = Firebase.shared.getCurrentUserID()
        let userRef = fs.collection("users").document(uid)
        userRef.updateData(["posts": FieldValue.arrayUnion([postID])])
    }
    
    func addPostToRated(postID: String) {
        let uid = Firebase.shared.getCurrentUserID()
        let userRef = fs.collection("users").document(uid)
        userRef.updateData(["ratedPosts": FieldValue.arrayUnion([postID])])
    }
    
    func getPostRatings(postOwner: String, postId: String, completion: @escaping ([RatingMan]) -> Void) {

        fs.collection("ratings")
            .whereField("postId", isEqualTo: postId)
            .getDocuments { (querySnapshot, error) in
                
            
            guard let documents = querySnapshot?.documents else {
                completion([])
                return
            }
            let ratings = documents.compactMap { documents -> RatingMan? in
                let data = documents.data()
                return RatingMan(userId: data["userId"] as? String ?? "",
                                 postId: data["postId"] as? String ?? "",
                                 rating: Decimal.init(data["rating"] as! Double),
                                 comment: data["comment"] as? String ?? ""
                )
            }
            completion(ratings)
        }
    }
    
    func getPostAverageRatings(postId: String) async throws -> Decimal {

        let queryRating = try await fs.collection("ratings")
            .whereField("postId", isEqualTo: postId)
            .getDocuments()
        
        guard !queryRating.documents.isEmpty else {
            print("empty rating docs")
            return 0.0
        }
        
        let sum = queryRating.documents.reduce(Decimal(0.0)) { partialResult, document in
            if let rating = document.data()["rating"] as? Double {
                return partialResult + Decimal(rating)
            }
            return partialResult
        }
        
        let avgRating = sum / Decimal(queryRating.documents.count)
        
        return avgRating
        
    }
        
    func addUser(uid: String, email: String, username: String) {
        let newUser = User(uid: uid, email: email, username: username)
        do {
            let userRef = fs.collection("users").document(uid)
            try userRef.setData(from: newUser) { error in
                if let error = error {
                    print(error)
                } else {
                    // test this
                    userRef.updateData(["createdAt": FieldValue.serverTimestamp()])
                    print("user added")
                }
            }
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
    }
        
    func addRatingToPost(postOwner: String, postId: String, userId: String, rating: Decimal, comment: String) async {
        let newRating = Rating(userId: userId, postId: postId, rating: rating, comment: comment)
        do {
            let snapshot = try await fs.collection("ratings")
                .whereField("userId", isEqualTo: Firebase.shared.getCurrentUserID())
                .getDocuments()
    
            if !snapshot.isEmpty {
                print("Document exists")
            } else {
                print("Document does not exist, adding rating")
                let ratingRef = fs.collection("ratings").document()
                try ratingRef.setData(from: newRating)
                try await ratingRef.updateData(["createdAt": FieldValue.serverTimestamp()])
            }
            
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
        
    }
}
