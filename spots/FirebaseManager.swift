//
//  spotsFirebase.swift
//  spots
//
//  Created by Aiden Gage on 12/30/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseDatabase

class FirebaseManager {
    
    let fs: Firestore
    let db: Database
    let storage: Storage
    
    init () {
        self.fs = Firestore.firestore()
        self.db = Database.database()
        self.storage = Storage.storage()
    }
    
    func getPostLocation(postCoords: (Double, Double)) {
        fs.collection("post").document(String(postCoords.0)).collection("post").document(String(postCoords.1)).getDocument { (document, error) in
            if let document = document, document.exists {
                print("Document data: \(document.data() ?? [:])")
            } else {
                print("Document does not exist")
            }
        }
    }
}
