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
    private var fs = Firestore.firestore()
    
    func getAllPosts(completion: @escaping ([PostMan]) -> Void) {
        fs.collectionGroup("posts").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                completion([])
                return
            }
            
            let posts = documents.compactMap { documents -> PostMan? in
                let data = documents.data()
                return PostMan(docId: documents.documentID,
                               userId: data["userID"] as? String ?? "",
                               title: data["name"] as? String ?? "",
                               description: data["description"] as? String ?? "",
                               images: data["images"] as? [String] ?? [],
                               coords: (data["xLoc"] as! Double, data["yLoc"] as! Double),
                               address: data["address"] as? String ?? "",
                               rating: Decimal.init(data["rating"] as! Double),
                               selectedActivity: data["selectedActivity"] as? String ?? ""
                )
            }
            completion(posts)
        }
    }
    
    func getUserPosts(completion: @escaping ([PostMan]) -> Void) {
        fs.collection("users").document(Firebase.shared.getCurrentUserID()).collection("posts").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                completion([])
                return
            }
            let posts = documents.compactMap { documents -> PostMan? in
                let data = documents.data()
                return PostMan(docId: documents.documentID,
                               userId: data["userID"] as? String ?? "",
                               title: data["name"] as? String ?? "",
                               description: data["description"] as? String ?? "",
                               images: data["images"] as? [String] ?? [],
                               coords: (data["xLoc"] as! Double, data["yLoc"] as! Double),
                               address: data["address"] as? String ?? "",
                               rating: Decimal.init(data["rating"] as! Double),
                               selectedActivity: data["selectedActivity"] as? String ?? ""
                )
            }
            completion(posts)
        }
    }
    
    func addPost(images: [String], name: String, address: String, rating: Decimal, description: String, coords: (xLoc: Double, yLoc: Double), selectedActivity: String) {
        let newPost = Post(images: images, name: name, address: address, rating: rating, description: description, xLoc: coords.xLoc, yLoc: coords.yLoc, ratings: [], userID: Firebase.shared.getCurrentUserID(), selectedActivity: selectedActivity)
        do {
            let postRef = fs.collection("users").document(Firebase.shared.getCurrentUserID()).collection("posts").document()
            try postRef.setData(from: newPost) { error in
                if let error = error {
                    print(error)
                } else {
                    self.addPostIDToUser(postID: postRef.documentID)
                    print("doc added")
                }
            }
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
    
    func getPostRatings(postOwner: String, postID: String, completion: @escaping ([RatingMan]) -> Void) {
        fs.collection("users").document(postOwner).collection("posts").document(postID).collection("ratings").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                completion([])
                return
            }
            let ratings = documents.compactMap { documents -> RatingMan? in
                let data = documents.data()
                return RatingMan(userID: data["user"] as? String ?? "",
                                 rating: Decimal.init(data["rating"] as! Double),
                                 comment: data["comment"] as? String ?? ""
                )
            }
            completion(ratings)
        }
    }
        
    func addUser(uid: String, email: String, username: String, posts: [String]) {
        let newUser = User(uid: uid, email: email, username: username, posts: posts, ratedPosts: [])
        do {
            try fs.collection("users").document(uid).setData(from: newUser) { error in
                if let error = error {
                    print(error)
                } else {
                    print("user added")
                }
            }
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
    }
        
    func addRatingToPost(postOwner: String, postID: String, userID: String, rating: Decimal, comment: String) async {
        let newRating = Rating(user: userID, rating: rating, comment: comment)
        do {
            let ratingRef = fs.collection("users").document(postOwner).collection("posts").document(postID).collection("ratings").document(Firebase.shared.getCurrentUserID())
            let snapshot = try await ratingRef.getDocument() //{ (document, error) in
            //                if let document = document, document.exists {
            if snapshot.exists {
                print("Document exists")
            } else {
                print("Document does not exist, adding rating")
                try ratingRef.setData(from: newRating)
                self.addPostToRated(postID: postID)
            }
            
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
        
    }
}
