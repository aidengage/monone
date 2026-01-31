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

struct PostMan: Identifiable {
    let id: String
    let userId: String
    let title: String
    let images: [String]
    let coords: (Double, Double)
    let address: String
    let rating: Decimal
    let selectedActivity: String
    
    init(from post: Post) {
        self.id = post.id
        self.userId = post.userId
        self.title = post.name
        self.images = post.images
        self.coords = (post.latitude, post.longitude)
        self.address = post.address
        self.rating = post.avgRating
        self.selectedActivity = post.selectedActivity
    }
    
    // initializes a post manager object
    init(docId: String, userId: String, title: String, images: [String], coords: (Double, Double), address: String, rating: Decimal, selectedActivity: String) {
        self.id = docId
        self.userId = userId
        self.title = title
        self.images = images
        self.coords = coords
        self.address = address
        self.rating = rating
        self.selectedActivity = selectedActivity
    }
    
    // creates marker at post coords
    func createMarkerForPost() -> some MapContent {
        return Marker(title, coordinate: CLLocationCoordinate2D(latitude: coords.0, longitude: coords.1))
            .tint(.red)
    }
}

extension Firebase {
    func getAllPosts(completion: @escaping ([PostMan]) -> Void) {
        Firebase.shared.getStore().collection("posts").getDocuments { (querySnapshot, error) in
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
        Firebase.shared.getStore().collection("posts")
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
        
        let newPost = Post(id: postId, userId: Firebase.shared.getCurrentUserID(), images: images, name: name, address: address, ratingCount: ratingCount, latitude: coords.lat, longitude: coords.long, avgRating: rating, selectedActivity: selectedActivity)
        
        let newRating = Rating(id: UUID().uuidString, userId: Firebase.shared.getCurrentUserID(), postId: postId, rating: rating, comment: comment)
        
        do {
            // adding post to posts collection
            let postRef = Firebase.shared.getStore().collection("posts").document(postId)
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
            let ratingRef = Firebase.shared.getStore().collection("ratings").document(newRating.id)
            
            try ratingRef.setData(from: newRating) { error in
                
                if let error = error {
                    print(error)
                } else {
                    ratingRef.updateData(["createdAt": FieldValue.serverTimestamp()])
                    print("rating added??")
                }
            }
            let avgRating = try await getPostAverageRatings(postId: postId)
//            try await postRef.updateData(["avgRating": avgRating])
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
    }
}
