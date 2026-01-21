//
//  FireStore.swift
//  spots
//
//  Created by Aiden Gage on 1/21/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

final class FireStore {
    private var fs = Firestore.firestore()
    private var postDict: [String:Any] = [:]
    var posts: [PostMan] = []
    
    private func resetPostDict() {
        self.postDict.removeAll()
    }
    
    func getAllPostsDocs() -> [String:Any] {
        // queries the "post" collection, getting every doc and storing them in a document dictionary
        // and prints everything in the dictionary (i dont think we need the above print function anymore then)
        fs.collectionGroup("posts").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("no docs: \(error)")
            } else {
                print("getting docs...")
                for document in querySnapshot!.documents {
                    self.postDict[document.documentID] = document.data()
                }
                print(self.postDict)
            }
        }
        return postDict
    }
    
    func getAllPosts(completion: @escaping ([PostMan]) -> Void) {
//        var postArray: [PostMan] = []
        fs.collectionGroup("posts").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                completion([])
                return
            }
            
            let posts = documents.compactMap { documents -> PostMan? in
                let data = documents.data()
                return PostMan(docId: documents.documentID,
                               userId: data["userID"] as? String ?? "",
                               title: data["name"] as? String ?? "",
                               description: data["description"] as? String ?? "",
                               images: data["images"] as? [String] ?? [],
                               coords: (data["xLoc"] as! Double, data["yLoc"] as! Double),
                               address: data["address"] as? String ?? "",
                               rating: Decimal.init(data["rating"] as! Double),
                               selectedActivity: data["selectedActivity"] as? String ?? ""
                )
            }
            completion(posts)
            
            // old
//            if let error = error {
//                print("error getting posts: \(error)")
//                completion([])
//            } else {
//                for document in querySnapshot!.documents {
//                    let data = document.data()
//                    print("doc data: \(data)")
//                    
//                    // setting all data
//                    let title = data["name"] as? String ?? ""
//                    let description = data["description"] as? String ?? ""
//                    let images = data["images"] as? [String] ?? []
//                    let address = data["address"] as? String ?? ""
//                    
//                    let userId: String = data["userID"] as? String ?? ""
//                    let selectedActivity: String = data["selectedActivity"] as? String ?? ""
//                    
//                    // this is a horrible line of code that somehow works to get double to decimal
//                    // loses some accuracy
//                    // figure out how to pull just a decimal
//                    let rating: Decimal = Decimal.init(data["rating"] as! Double) /*data["rating"] as? Decimal ?? 0.0*/
//                    
////                    let ratings = data["ratings"] as? [Rating] ?? []
//                    
//                    var xLoc: Double = 0.0
//                    var yLoc: Double = 0.0
//                    
//                    if let x = data["xLoc"] as? Double, let y = data["yLoc"] as? Double {
//                        xLoc = x
//                        yLoc = y
//                    } else {
//                        print("No coordinates found for post '\(data["name"] as? String ?? "unknown")'")
//                    }
//                    
//                    // creating post from set data with post manager (PostMan)
//                    let post = PostMan(
//                        docId: document.documentID,
//                        userId: userId,
//                        title: title,
//                        description: description,
//                        images: images,
//                        coords: (xLoc, yLoc),
//                        address: address,
//                        rating: rating,
//                        selectedActivity: selectedActivity
//                        // maybe add user ratings in here idk
////                        ratings: ratings
//                    )
////                    print(post)
//                    // stores to the postArray
//                    postArray.append(post)
//                }
//                //this completion handler triggers handleLoadedPosts method in ContentView.swift and its only triggered once the posts are loaded
//                completion(postArray)
        }
    }
    
    //this completion handler is triggered once the posts are loaded, and it updates the posts state variable because there is a state change in the posts variable (going from empty to having data)
//    func handleLoadedPosts(loadedPosts: [PostMan], posts: inout [PostMan]) {
//        print("\(loadedPosts.count) posts from Firebase")
//        for (index, post) in loadedPosts.enumerated() {
//            print("   Post \(index + 1): \(post.title) - Coords: (\(post.coords.0), \(post.coords.1)), Rating: \(post.rating)")
////            print(post)
//        }
//        posts = loadedPosts
//        print("Updated posts state variable. Map will now render markers.")
//    }
    
    func getUserPosts() -> [String:Any] {
        var userPosts: [String:Any] = [:]
        fs.collection("users").document(FireIntegration.shared.getCurrentUserID()).collection("posts").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("no user docs... \(error)")
            } else {
                for document in querySnapshot!.documents {
                    userPosts[document.documentID] = document.data()
                }
            }
        }
        return userPosts
    }
    
    func addPost(images: [String], name: String, address: String, rating: Decimal, description: String, coords: (xLoc: Double, yLoc: Double), selectedActivity: String) {
        let newPost = Post(images: images, name: name, address: address, rating: rating, description: description, xLoc: coords.xLoc, yLoc: coords.yLoc, ratings: [], userID: FireIntegration.shared.getCurrentUserID(), selectedActivity: selectedActivity)
        do {
            let postRef = fs.collection("users").document(FireIntegration.shared.getCurrentUserID()).collection("posts").document()
            try postRef.setData(from: newPost) { error in
                if let error = error {
                    print(error)
                } else {
                    self.addPostIDToUser(postID: postRef.documentID)
                    print("doc added")
                }
            }
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
    }
    
    func addPostIDToUser(postID: String) {
        let uid = FireIntegration.shared.getCurrentUserID()
        let userRef = fs.collection("users").document(uid)
        userRef.updateData(["posts": FieldValue.arrayUnion([postID])])
    }
}
