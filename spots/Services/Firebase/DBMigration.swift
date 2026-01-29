//
//  DBMigration.swift
//  spots
//
//  Created by Aiden Gage on 1/29/26.
//

import SwiftUI

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
        print("migrating posts subcollection to top level")
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
