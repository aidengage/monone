//
//  DBMigration.swift
//  spots
//
//  Created by Aiden Gage on 1/29/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

class DBMigration {
    func migrateDatabase() async {
        print("migrating db")
        
        do {
            try await migratePosts()
            try await migrateRatings()
            try await cleanUserDocs()
            print("migrationg complete..............")
        } catch {
            print("migration failed with: \(error)")
        }
    }
    
    func migratePosts() async throws {
        print("  migrating posts subcollection to top level")
        
        let usersSnapshot = try await Firebase.shared.store.fs.collection("users").getDocuments()
        
        for userDoc in usersSnapshot.documents {
            let userId = userDoc.documentID
            print("    processing posts for user: \(userId)")
            
            let postsSnapshot = try await Firebase.shared.store.fs.collection("users")
                .document(userId)
                .collection("posts")
                .getDocuments()
            
            print("    found \(postsSnapshot.count) posts")
            
            for postDoc in postsSnapshot.documents {
                let postId = postDoc.documentID
                let postData = postDoc.data()
                var newPostData: [String: Any] = [:]
                
                newPostData["userId"] = userId
                newPostData["name"] = postData["name"]
                newPostData["address"] = postData["address"]
                newPostData["selectedActivity"] = postData["selectedActivity"]
                newPostData["images"] = postData["images"] ?? []
                
                if let xCoord = postData["xLoc"] as? Double, let yCoord = postData["yLoc"] as? Double {
                    newPostData["latitude"] = xCoord
                    newPostData["longitude"] = yCoord
                }
                
                if let username = userDoc.data()["username"] as? String {
                    newPostData["username"] = username
                }
                
                let ratingsData = try await calcAvgRating(userId: userId, postId: postId)
                newPostData["avgRating"] = ratingsData.avgRating
                newPostData["ratingCount"] = ratingsData.count
                
                newPostData["createdAt"] = FieldValue.serverTimestamp()
                newPostData["updatedAt"] = FieldValue.serverTimestamp()
                
                try await Firebase.shared.store.fs.collection("posts").document(postId).setData(newPostData)
                
                print("      migrated post: \(postId)")
            }
        }
        print("  all posts migrated")
    }
    
    func migrateRatings() async throws {
        print("migrating ratings subcollection to top level")
        
        let usersSnapshot = try await Firebase.shared.store.fs.collection("users").getDocuments()
        
        print("  migrating ratings.....")
        
        for userDoc in usersSnapshot.documents {
            let userId = userDoc.documentID
            
            let postsSnapshot = try await Firebase.shared.store.fs.collection("users")
                .document(userId)
                .collection("posts")
                .getDocuments()
            
            for postDoc in postsSnapshot.documents {
                let postId = postDoc.documentID
                
                let ratingsSnapshot = try await Firebase.shared.store.fs.collection("users")
                    .document(userId)
                    .collection("posts")
                    .document(postId)
                    .collection("ratings")
                    .getDocuments()
                
                print("    found user \(userId)'s rating for post \(postId)")
                
                for ratingDoc in ratingsSnapshot.documents {
                    let ratingId = UUID().uuidString
                    // ratingDoc.documentID // this is still user id
                    let ratingData = ratingDoc.data()
                    var newRatingData: [String: Any] = [:]
                    
                    newRatingData["postId"] = postId
                    newRatingData["userId"] = ratingData["user"]
                    newRatingData["rating"] = ratingData["rating"]
                    newRatingData["comment"] = ratingData["comment"]
                    newRatingData["createdAt"] = FieldValue.serverTimestamp()
                    
                    try await Firebase.shared.store.fs.collection("ratings")
                        .document(ratingId)
                        .setData(newRatingData)
                    
                    print("      migrated rating: \(ratingId)")
                    
                }
            }
        }
        print("  migrated ratings....")
    }
    
    func calcAvgRating(userId: String, postId: String) async throws -> (avgRating: Decimal, count: Int) {
        print("calculating average rating of post")
        
        let ratingsSnapshot = try await Firebase.shared.store.fs.collection("users")
            .document(userId)
            .collection("posts")
            .document(postId)
            .collection("ratings")
            .getDocuments()
        
        guard !ratingsSnapshot.documents.isEmpty else {
            return (0.0, 0)
        }
        
        let sum = ratingsSnapshot.documents.reduce(Decimal(0.0)) { partialResult, doc in
            let rating = doc.data()["rating"] as? Double ?? 0.0
            return partialResult + Decimal(rating)
        }
        
        let avgRating = sum / Decimal(ratingsSnapshot.documents.count)
        
        return (avgRating, ratingsSnapshot.documents.count)
    }
    
    func cleanUserDocs() async throws {
        print("deleting posts and rated posts lists")
        
        let usersSnapshot = try await Firebase.shared.store.fs.collection("users").getDocuments()
        
        for userDoc in usersSnapshot.documents {
            let userId = userDoc.documentID
            
            try await Firebase.shared.store.fs.collection("users")
                .document(userId)
                .updateData([
                    "posts": FieldValue.delete(),
                    "ratedPosts": FieldValue.delete()
                ])
            print("    cleaned up user: \(userId)")
        }
        print("  user cleanup complete")
    }
    
    func verifyMigration() async throws {
        print("\n=== verifying... ===")
        
        let postsCount = try await Firebase.shared.store.fs.collection("posts").getDocuments().documents.count
        print("  top level posts count: \(postsCount)")
        
        let ratingsCount = try await Firebase.shared.store.fs.collection("ratings").getDocuments().documents.count
        print("  top level ratings count: \(ratingsCount)")
        
        let samplePost = try await Firebase.shared.store.fs.collection("posts").limit(to: 1).getDocuments().documents.first
        if let post = samplePost {
            print("\nSample post verification:")
            print("    Post ID: \(post.documentID)")
            print("    User ID: \(post.data()["userId"] ?? "missing")")
            print("    Average Rating: \(post.data()["avgRating"] ?? "missing")")
            print("    Rating Count: \(post.data()["ratingCount"] ?? "missing")")
        }
        
    }
}

struct FireMigrateButton: View {
    var body: some View {
        Button("migrate db...") {
            Task {
                let dbm = DBMigration()
                await dbm.migrateDatabase()
                try? await dbm.verifyMigration()
            }
        }
    }
}
