//
//  RatingManager.swift
//  spots
//
//  Created by Aiden Gage on 1/19/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

// codable rating obejct to send to firebase db
struct Rating: Codable, Identifiable {
    let id: String
    let userId: String
    let postId: String
    let rating: Decimal
    let comment: String
}

extension Firebase {
    func getPostRatings(postOwner: String, postId: String, completion: @escaping ([Rating]) -> Void) {

        getStore().collection("ratings")
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

        let queryRating = try await getStore().collection("ratings")
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
    
    func addRatingToPost(postOwner: String, postId: String, userId: String, rating: Decimal, comment: String) async {
        let newRating = Rating(id: UUID().uuidString, userId: userId, postId: postId, rating: rating, comment: comment)
        do {
            let snapshot = try await getStore().collection("ratings")
                .whereField("userId", isEqualTo: getCurrentUserID())
                .whereField("postId", isEqualTo: postId)
                .getDocuments()
    
            if !snapshot.isEmpty {
//                print(snapshot)
                print("Document exists")
            } else {
                print("Document does not exist, adding rating")
                let ratingRef = getStore().collection("ratings").document(newRating.id)
                try ratingRef.setData(from: newRating)
                try await ratingRef.updateData(["createdAt": FieldValue.serverTimestamp()])
                let postRef = getStore().collection("posts").document(postId)
//                    .whereField("postId", isEqualTo: postId)
                try await postRef.updateData(["avgRating": getPostAverageRatings(postId: postId)])
//                    .updateData(["avgRating": Firebase.shared.getPostAverageRatings(postId: postId)])
            }
            
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
        
    }
    
    func deleteRatingsOfPost(postId: String/*, userId: String*/) async {
        do {
            let query = try await getStore().collection("ratings")
                .whereField("postId", isEqualTo: postId)
//                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            guard !query.documents.isEmpty else {
                print("no ratings found")
                return
            }
            
            let batch = getStore().batch()
            
            for ratings in query.documents {
                batch.deleteDocument(ratings.reference)
            }
            
            try await batch.commit()
            print("successfully deleted \(query.documents.count) ratings associated with post...")
        } catch {
            print("error deleting ratings: \(error.localizedDescription)")
        }
    }
    
    func startRatingListener() {
        stopRatingListener()
        
        ratingListener = getStore().collection("ratings").addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("error getting ratings: \(error.localizedDescription)")
            }
            
            guard let documents = snapshot?.documents else {
                print("No ratings found")
                self.ratings = []
                return
            }
            
            self.ratings = documents.compactMap { document in
                do {
                    let rating = try document.data(as: Rating.self)
                    return rating
                } catch {
                    print("error decoding rating \(document.documentID): \(error.localizedDescription)")
                    return nil
                }
            }
        }
        print("rating count in post: \(self.ratings.count)")
    }
    
    func stopRatingListener() {
        ratingListener?.remove()
        ratingListener = nil
    }
}
