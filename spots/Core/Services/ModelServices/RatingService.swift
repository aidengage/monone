//
//  RatingService.swift
//  spots
//
//  Created by Aiden Gage on 6/25/26.
//

import SwiftUI
import Firebase
import FirebaseFirestore

protocol RatingServiceProtocol {
    func getPostRatings(postOwner: String, postId: String, completion: @escaping ([Rating]) -> Void)
    func getPostAverageRatings(postId: String) async throws -> Decimal
    func ratingUpdateAvg(postId: String) async
    func ratingUpdateComment(ratingId: String, newComment: String) async
    func addRatingToPost(postOwner: String, postId: String, userId: String, rating: Decimal, comment: String) async
    func removeRatingFromPost(postId: String) async
}

@Observable
class RatingService: RatingServiceProtocol {
    private let authService: authServiceProtocol
    private let dbService: dbServiceProtocol
    
    init(authService: authServiceProtocol, dbService: dbServiceProtocol) {
        self.authService = authService
        self.dbService = dbService
    }
    
    func getPostRatings(postOwner: String, postId: String, completion: @escaping ([Rating]) -> Void) {

        dbService.getStore().collection("ratings")
            .whereField("postId", isEqualTo: postId)
            .getDocuments { (querySnapshot, error) in
                
            
            guard let documents = querySnapshot?.documents else {
                completion([])
                return
            }
            let ratings = documents.compactMap { documents -> Rating? in
                let data = documents.data()
                return Rating(id: documents.documentID,
                                 userId: data["userId"] as? String ?? "",
                                 postId: data["postId"] as? String ?? "",
                                 rating: Decimal.init(data["rating"] as! Double),
                                 comment: data["comment"] as? String ?? ""
                )
            }
            completion(ratings)
        }
    }
    
    func getPostAverageRatings(postId: String) async throws -> Decimal {

        let queryRating = try await dbService.getStore().collection("ratings")
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
    
    func ratingUpdateAvg(postId: String) async {
        do {
            let avgRating = try await getPostAverageRatings(postId: postId)
            let postRef = dbService.getStore().collection("posts").document(postId)
            try await postRef.updateData(["avgRating": avgRating])
        } catch {
            print("error handling average rating: \(error)")
        }
    }
    
    func ratingUpdateComment(ratingId: String, newComment: String) async {
        do {
            let ratingRef = dbService.getStore().collection("ratings").document(ratingId)
            try await ratingRef.updateData(["comment": newComment])
        } catch {
            print("error updating rating comment...")
            print(error.localizedDescription)
        }
    }
    
    func addRatingToPost(postOwner: String, postId: String, userId: String, rating: Decimal, comment: String) async {
        let newRating = Rating(id: UUID().uuidString, userId: userId, postId: postId, rating: rating, comment: comment)
        do {
            let snapshot = try await dbService.getStore().collection("ratings")
                .whereField("userId", isEqualTo: authService.getCurrentUserID())
                .whereField("postId", isEqualTo: postId)
                .getDocuments()
    
            if !snapshot.isEmpty {
                print("Document exists")
            } else {
                print("Document does not exist, adding rating")
                let ratingRef = dbService.getStore().collection("ratings").document(newRating.id)
                try ratingRef.setData(from: newRating)
                try await ratingRef.updateData(["createdAt": FieldValue.serverTimestamp()])
                let postRef = dbService.getStore().collection("posts").document(postId)
                await ratingUpdateAvg(postId: postId)
                
                try await postRef.updateData(["ratingCount": FieldValue.increment(Int64(1))])
            }
            
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
        
    }
    
    
    func removeRatingFromPost(postId: String) async {
        do {
            let query = try await dbService.getStore().collection("ratings")
                .whereField("postId", isEqualTo: postId)
                .whereField("userId", isEqualTo: authService.getCurrentUserID())
                .getDocuments()
            
            let batch = dbService.getStore().batch()
            
            for rating in query.documents {
                batch.deleteDocument(rating.reference)
            }
            
            let postRef = dbService.getStore().collection("posts").document(postId)
            
            batch.updateData(["ratingCount": FieldValue.increment(Int64(-1))], forDocument: postRef)
            
            try await batch.commit()
            await ratingUpdateAvg(postId: postId)
            print("successfully removed your rating from post...")
        } catch {
            print("error removing your rating from post: \(error.localizedDescription)")
        }
    }
    
    
    
    
}
