//
//  PostService.swift
//  spots
//
//  Created by Aiden Gage on 6/25/26.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

protocol PostServiceProtocol {
    func addPost(images: [UIImage], imagesUUIDs: [String], name: String, address: String, rating: Decimal, ratingCount: Int, comment: String, coords: (lat: Double, long: Double), selectedActivity: String) async throws
    func postUpdateActivity(postId: String, newActivity: ActivityType) async
    func postUpdateName(postId: String, newName: String) async
    func postUpdateAddress(postId: String, newAddress: String) async
    func postUpdateLocation(postId: String, newLocation: GeoPoint) async
    func deletePostBatch(postId: String) async
    func deletePost(postId: String) async
    func deleteImagesByUUID(postId: String) async
    func deletePostImages(postId: String) async
}

@Observable
class PostService: PostServiceProtocol {
    private let authService: authServiceProtocol
    private let dbService: dbServiceProtocol
    private let storageService: storageServiceProtocol
    
    init(authService: authServiceProtocol, dbService: dbServiceProtocol, storageService: storageServiceProtocol) {
        self.authService = authService
        self.dbService = dbService
        self.storageService = storageService
    }
    
    func addPost(images: [UIImage], imagesUUIDs: [String], name: String, address: String, rating: Decimal, ratingCount: Int, comment: String, coords: (lat: Double, long: Double), selectedActivity: String) async throws {
        let postId = UUID().uuidString
        var imageURLs: [String] = []
        
        let newPost = try await Post(id: postId, userId: authService.getCurrentUserID(), images: imageURLs, name: name, address: address, ratingCount: ratingCount, latitude: coords.lat, longitude: coords.long, avgRating: rating, selectedActivity: selectedActivity)
        
        let newRating = try await Rating(id: UUID().uuidString, userId: authService.getCurrentUserID(), postId: postId, rating: rating, comment: comment)
        
        do {
            // adding post to posts collection
            let postRef = dbService.getStore().collection("posts").document(postId)
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
                let ratingRef = dbService.getStore().collection("ratings").document(newRating.id)
                
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
                let path = "posts/\(authService.getCurrentUserID())/\(postId)/user_photo_\(index)"
                let url = try await smartFormat(image: image, path: path)
                imageURLs.append(url)
            }
            
            try await dbService.getStore().collection("posts").document(postId).updateData(["images": imageURLs])
            
        } catch {
            print("creating doc: \(error.localizedDescription)")
        }
    }
    
    
    // db manipulation functions
    // already tested
    func postUpdateActivity(postId: String, newActivity: ActivityType) async {
        let postRef = dbService.getStore().collection("posts").document(postId)
        do {
            try await postRef.updateData(["selectedActivity": newActivity.displayActivity])
            await dbService.docUpdatedAt(docRef: postRef)
        } catch {
            print("error updating activity")
            print(error.localizedDescription)
        }
    }
    
    // need to test
    func postUpdateName(postId: String, newName: String) async {
        let postRef = dbService.getStore().collection("posts").document(postId)
        do {
            try await postRef.updateData(["name": newName])
            await dbService.docUpdatedAt(docRef: postRef)
        } catch {
            print("error updating name")
            print(error.localizedDescription)
        }
    }
    
    // need to test
    func postUpdateAddress(postId: String, newAddress: String) async {
        let postRef = dbService.getStore().collection("posts").document(postId)
        do {
            try await postRef.updateData(["address": newAddress])
            await dbService.docUpdatedAt(docRef: postRef)
        } catch {
            print("error updating address")
            print(error.localizedDescription)
        }
    }
    
    // need to test
    func postUpdateLocation(postId: String, newLocation: GeoPoint) async {
        let postRef = dbService.getStore().collection("posts").document(postId)
        do {
            try await postRef.updateData(["latitude": newLocation.latitude])
            try await postRef.updateData(["longitude": newLocation.longitude])
            await dbService.docUpdatedAt(docRef: postRef)
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
    
    func deleteRatingsOfPost(postId: String) async {
        do {
            let query = try await dbService.getStore().collection("ratings")
                .whereField("postId", isEqualTo: postId)
                .getDocuments()
            
            guard !query.documents.isEmpty else {
                print("no ratings found")
                return
            }
            
            let batch = dbService.getStore().batch()
            
            for ratings in query.documents {
                batch.deleteDocument(ratings.reference)
            }
            
            try await batch.commit()
            print("successfully deleted \(query.documents.count) ratings associated with post...")
        } catch {
            print(" deleting ratings: \(error.localizedDescription)")
        }
    }
    
    
    func deletePost(postId: String) async {
        // should be able to make this delete multiple by changing to an array of post ids and adding each to a batch
        do {
            let batch = dbService.getStore().batch()
            batch.deleteDocument(dbService.getStore().collection("posts").document(postId))
            try await batch.commit()
        } catch {
            print(" deleting post: \(error.localizedDescription)")
        }
    }
    
    func deleteImagesByUUID(postId: String) async {
        do {
            let imageUUIDs: [String] = try await dbService.getStore().collection("posts").document(postId).getDocument()["images"] as? [String] ?? []
            
            for uuid in imageUUIDs {
                let imageRef = storageService.getStorage().reference().child(uuid)
                try await imageRef.delete()
            }
        } catch {
            print(" deleting images: \(error.localizedDescription)")
        }
        
    }
    
    func deletePostImages(postId: String) async {
        do {
            let imgUrls: [String] = try await dbService.getStore().collection("posts").document(postId).getDocument()["images"] as? [String] ?? []
            for url in imgUrls {
                try await storageService.getStorage().reference(forURL: url).delete()
            }
        } catch {
            print(" error deleting images: \(error.localizedDescription)")
        }
    }
    
    
    
}
