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
    }
    
    func calcAvgRating(userId: String, postId: String) async throws -> (avgRating: Decimal, count: Int) {
        print("calculating average rating of post")
        
        
    }
    
    func cleanUserDocs() async throws {
        print("deleting posts and rated posts lists")
    }
    
    func verifyMigration() async throws {
        print("\n=== verifying... ===")
    }
}
