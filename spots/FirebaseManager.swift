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
    
    func getDocs() {
        fs.collection("post").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("get fucked idiot: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
}
    
struct post: Identifiable {
    @DocumentID var id: String?
    var image: String?
    var name: String?
    var description: String?
    var rating: Double?
    var location: (Double?, Double?)
    var address: String?
}

