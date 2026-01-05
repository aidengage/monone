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
                print("hello: \(error)")
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
//                    if self.docDict[document.documentID] == document.data() {
//                        
//                    }
                    self.docDict[document.documentID] = document.data()
                }
                print(self.docDict)
            }
        }
    }
    
    func addPost(image: String, name: String, address: String, rating: Double, description: String, coords: (xLoc: Double, yLoc: Double)) {
        let newPost = Post(image: image, name: name, address: address, rating: rating, description: description, xLoc: coords.xLoc, yLoc: coords.yLoc)
        do {
            try fs.collection("post").addDocument(from: newPost) { error in
                if let error = error {
                    print("shit broke adding files")
                } else {
                    print("doc added")
                }
            }
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
    }
}
    
struct Post: Codable {
//    @DocumentID var id: String?
    var image: String?
    var name: String?
    var address: String?
    var rating: Double?
    var description: String?
//    var location: (Double?, Double?)
    var xLoc: Double?
    var yLoc: Double?
}

