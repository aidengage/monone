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

class FirebaseManager { // add observableobject?
    
    let fs: Firestore
    let db: Database
    let storage: Storage
    var docDict: [String:Any]
    
    init () {
        self.fs = Firestore.firestore()
        self.db = Database.database()
        self.storage = Storage.storage()
        self.docDict = [:]
    }
    
    func printDocs() {
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
    
    func getDocs() {
//        let docArray: [QuerySnapshot]
        fs.collection("post").getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("no docs: \(error)")
            } else {
                print("getting docs...")
                for document in querySnapshot!.documents {
                    self.docDict[document.documentID] = document.data()
                    print(self.docDict)
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

