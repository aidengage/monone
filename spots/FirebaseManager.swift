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
    
    func getPostByName(postName: String) {
        fs.collection("post").document(postName).getDocument { (document, error) in
            if let document = document, document.exists {
                print("Document data: \(document.data() ?? [:])")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getPostById(postID: String) {
        fs.collection("post").document(postID).getDocument { (document, error) in
            if let document = document, document.exists {
                print("document does exist")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func addSnapListener() {
        fs.collection("post").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error connecting: ", error)
            } else {
                print("connected to firestore")
            }
        }
    }
}
