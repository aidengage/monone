//
//  spotsFirebase.swift
//  spots
//
//  Created by Aiden Gage on 12/30/25.
//

import SwiftUI
import PhotosUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseDatabase

class FirebaseManager { // add observableobject?
    
    let fs: Firestore
    let db: Database
    let storage: Storage
    var docDict: [String:Any]
    var selectedItems: [PhotosPickerItem]
    
    init () {
        self.fs = Firestore.firestore()
        self.db = Database.database()
        self.storage = Storage.storage()
        self.docDict = [:]
        self.selectedItems = []
    }
    
    func storeImages() {
        let fileName: String
        let storageRef = storage.reference()
        let imageRef = storageRef.child("spots-image-uplaod-")
        
        
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
                    self.docDict[document.documentID] = document.data()
                }
                print(self.docDict)
            }
        }
    }
    
    func getPosts(completion: @escaping ([PostMan]) -> Void) {
        var postArray: [PostMan] = []
        fs.collection("post").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("error getting posts: \(error)")
                completion([])
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    let title = data["name"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let image = data["imageURL"] as? String ?? ""  
                    let address = data["address"] as? String ?? ""
                    
                    var xLoc: Double = 0.0
                    var yLoc: Double = 0.0
                    
                    if let x = data["xLoc"] as? Double, let y = data["yLoc"] as? Double {
                        xLoc = x
                        yLoc = y
                    } else {
                        print("No coordinates found for post '\(data["name"] as? String ?? "unknown")'")
                    }
                    
                    
                    let post = PostMan(
                        docId: document.documentID,
                        title: title,
                        description: description,
                        image: image,
                        coords: (xLoc, yLoc),
                        address: address
                    )
                    postArray.append(post)
                }
                //this completion handler triggers handleLoadedPosts method in ContentView.swift and its only triggered once the posts are loaded                
                completion(postArray)
            }
        }
    }
    
    func addPost(image: String, name: String, address: String, rating: Double, description: String, coords: (xLoc: Double, yLoc: Double)) {
        let newPost = Post(image: image, name: name, address: address, rating: rating, description: description, xLoc: coords.xLoc, yLoc: coords.yLoc)
        do {
            try fs.collection("post").addDocument(from: newPost) { error in
                if let error = error {
                    print(error)
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

