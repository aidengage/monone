//
//  PostService.swift
//  spots
//
//  Created by Aiden Gage on 6/25/26.
//

import SwiftUI
import Firebase
import FirebaseFirestore

protocol PostServiceProtocol {
    
}

@Observable
class PostService: PostServiceProtocol {
    private let authService: authServiceProtocol
    private let dbService: dbServiceProtocol
    
    init(authService: authServiceProtocol, dbService: dbServiceProtocol) {
        self.authService = authService
        self.dbService = dbService
    }
    
    func addPost(images: [UIImage], imagesUUIDs: [String], name: String, address: String, rating: Decimal, ratingCount: Int, comment: String, coords: (lat: Double, long: Double), selectedActivity: String) async {
        let postId = UUID().uuidString
        var imageURLs: [String] = []
        
        let newPost = Post(id: postId, userId: getCurrentUserID(), images: imageURLs, name: name, address: address, ratingCount: ratingCount, latitude: coords.lat, longitude: coords.long, avgRating: rating, selectedActivity: selectedActivity)
        
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
                        postRef.updateData(["ratingCount": FieldValue.increment(Int64(1))])
                        print("rating added??")
                    }
                }
            }
            
            for (index, image) in images.enumerated() {
                let path = "posts/\(Firebase.shared.getCurrentUserID())/\(postId)/user_photo_\(index)"
                let url = try await smartFormat(image: image, path: path)
                imageURLs.append(url)
            }
            
            try await getStore().collection("posts").document(postId).updateData(["images": imageURLs])
            
        } catch {
            print("creating doc: \(error.localizedDescription)")
        }
    }
    
    
    // db manipulation functions
    // already tested
    func postUpdateActivity(postId: String, newActivity: ActivityType) async {
        let postRef = getStore().collection("posts").document(postId)
        do {
            try await postRef.updateData(["selectedActivity": newActivity.displayActivity])
            await docUpdatedAt(docRef: postRef)
        } catch {
            print("error updating activity")
            print(error.localizedDescription)
        }
    }
    
    // need to test
    func postUpdateName(postId: String, newName: String) async {
        let postRef = getStore().collection("posts").document(postId)
        do {
            try await postRef.updateData(["name": newName])
            await docUpdatedAt(docRef: postRef)
        } catch {
            print("error updating name")
            print(error.localizedDescription)
        }
    }
    
    // need to test
    func postUpdateAddress(postId: String, newAddress: String) async {
        let postRef = getStore().collection("posts").document(postId)
        do {
            try await postRef.updateData(["address": newAddress])
            await docUpdatedAt(docRef: postRef)
        } catch {
            print("error updating address")
            print(error.localizedDescription)
        }
    }
    
    // need to test
    func postUpdateLocation(postId: String, newLocation: GeoPoint) async {
        let postRef = getStore().collection("posts").document(postId)
        do {
            try await postRef.updateData(["latitude": newLocation.latitude])
            try await postRef.updateData(["longitude": newLocation.longitude])
            await docUpdatedAt(docRef: postRef)
        } catch {
            print("error updating location")
            print(error.localizedDescription)
        }
    }
    
    
    // delete post data funcitons
    func deletePostBatch(postId: String) async {
        await deleteRatingsOfPost(postId: postId)
        await deletePostImages(postId: postId)
        await deletePost(postId: postId)
    }
    
    func deletePost(postId: String) async {
        // should be able to make this delete multiple by changing to an array of post ids and adding each to a batch
        do {
            let batch = getStore().batch()
            batch.deleteDocument(getStore().collection("posts").document(postId))
            try await batch.commit()
        } catch {
            print(" deleting post: \(error.localizedDescription)")
        }
    }
    
    func deleteImagesByUUID(postId: String) async {
        do {
            let imageUUIDs: [String] = try await getStore().collection("posts").document(postId).getDocument()["images"] as? [String] ?? []
            
            for uuid in imageUUIDs {
                let imageRef = storage.storage.reference().child(uuid)
                try await imageRef.delete()
            }
        } catch {
            print(" deleting images: \(error.localizedDescription)")
        }
        
    }
    
    func deletePostImages(postId: String) async {
        do {
            let imgUrls: [String] = try await getStore().collection("posts").document(postId).getDocument()["images"] as? [String] ?? []
            for url in imgUrls {
                try await storage.storage.reference(forURL: url).delete()
            }
        } catch {
            print(" error deleting images: \(error.localizedDescription)")
        }
    }
    
    
    
}
