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
import FirebaseAuth

// codable post object to allow encoding data to send to firebase to to
// needs work
struct Post: Codable {
    var images: [String?]
    var name: String?
    var address: String?
    var rating: Decimal?
    var description: String?
    var xLoc: Double?
    var yLoc: Double?
    var ratings: [String?]
    var userID: String?
}

// codable user obejct to send to firebase database
struct User: Codable {
    var uid: String?
    var email: String?
    var username: String?
    var posts: [String?]
    var ratedPosts: [String?]
}

// codable rating obejct to send to firebase db
struct Rating: Codable {
    var user: String?
    var rating: Decimal?
    var comment: String?
}

// big firebase
final class FirebaseManager {
    // global firebasemanager for photo picker i think?
    static let shared = FirebaseManager()
    
    // firebase relevant variables
    let fs: Firestore
    let db: Database
    let storage: Storage
    var docDict: [String:Any]
    
    // firebase manager initializer
    init () {
        self.fs = Firestore.firestore()
        self.db = Database.database()
        let app = FirebaseApp.app()!
        self.storage = Storage.storage(app: app)
        self.docDict = [:]
    }
    
    
    
    // **  below is user database querying  ** //
    
    // adds  user to "users" collection in firebase
    // maybe rework this just to send the uid and posts
    func addUser(uid: String, email: String, username: String, posts: [String]) {
        let newUser = User(uid: uid, email: email, username: username, posts: posts, ratedPosts: [])
        do {
            try fs.collection("users").document(uid).setData(from: newUser) { error in
                if let error = error {
                    print(error)
                } else {
                    print("user added")
                }
            }
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
    }
    
    // gets and returns the id of current user logged in
    func getCurrentUserID() -> String {
        let currentUser = Auth.auth().currentUser
        let userID = currentUser?.uid ?? ""
        return userID
    }
    
    // adds a specific post id (post document id) to the users posts array in database
    // use this as template for things like saved posts, followed and following
    func addPostIDToUser(postID: String) {
        let uid = getCurrentUserID()
        let userRef = fs.collection("users").document(uid)
        userRef.updateData(["posts": FieldValue.arrayUnion([postID])])
    }
    
    
    
    // **  below is post database querying, currently reworking for users and posts  ** //
    
    // queries the "post" collection, getting every doc and storing them in a document dictionary
    // and prints everything in the dictionary (i dont think we need the above print function anymore then)
    func getDocs() {
        fs.collectionGroup("posts").getDocuments { (querySnapshot, error) in
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
    
    // get posts function queries "post" collection and sets all the data to its corresponding post values
    func getPosts(completion: @escaping ([PostMan]) -> Void) {
        var postArray: [PostMan] = []
        fs.collectionGroup("posts").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("error getting posts: \(error)")
                completion([])
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    print("doc data: \(data)")
                    
                    // setting all data
                    let title = data["name"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let images = data["images"] as? [String] ?? []
                    let address = data["address"] as? String ?? ""
                    
                    let userId: String = data["userID"] as? String ?? ""
                    
                    // this is a horrible line of code that somehow works to get double to decimal
                    // loses some accuracy
                    // figure out how to pull just a decimal
                    let rating: Decimal = Decimal.init(data["rating"] as! Double) /*data["rating"] as? Decimal ?? 0.0*/
                    
//                    let ratings = data["ratings"] as? [Rating] ?? []
                    
                    var xLoc: Double = 0.0
                    var yLoc: Double = 0.0
                    
                    if let x = data["xLoc"] as? Double, let y = data["yLoc"] as? Double {
                        xLoc = x
                        yLoc = y
                    } else {
                        print("No coordinates found for post '\(data["name"] as? String ?? "unknown")'")
                    }
                    
                    // creating post from set data with post manager (PostMan)
                    let post = PostMan(
                        docId: document.documentID,
                        userId: userId,
                        title: title,
                        description: description,
                        images: images,
                        coords: (xLoc, yLoc),
                        address: address,
                        rating: rating,
                        // maybe add user ratings in here idk
//                        ratings: ratings
                    )
//                    print(post)
                    // stores to the postArray
                    postArray.append(post)
                }
                //this completion handler triggers handleLoadedPosts method in ContentView.swift and its only triggered once the posts are loaded                
                completion(postArray)
            }
        }
    }
    
    // creates post with these params and adds to the "post" collection
    func addPost(images: [String], name: String, address: String, rating: Decimal, description: String, coords: (xLoc: Double, yLoc: Double)) {
        let newPost = Post(images: images, name: name, address: address, rating: rating, description: description, xLoc: coords.xLoc, yLoc: coords.yLoc, ratings: [], userID: getCurrentUserID())
        do {
            let postRef = fs.collection("users").document(getCurrentUserID()).collection("posts").document()
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
    
    
    
    
    // ** below relates to adding a rating document to a post's rating collection
    
    func addRatingToPost(postOwner: String, postID: String, userID: String, rating: Decimal, comment: String) {
        let newRating = Rating(user: userID, rating: rating, comment: comment)
        do {
            let ratingRef = fs.collection("users").document(postOwner).collection("posts").document(postID).collection("ratings").document(FirebaseManager.shared.getCurrentUserID())
            try ratingRef.setData(from: newRating) { error in
                if let error = error {
                    print(error)
                } else {
                    self.addPostToRated(postID: postID)
                    print("rating added")
                }
            }
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
    }
    
//    func RatingExists(postOwner: String, postID: String, userID: String) -> Bool {
//        let query = fs.collection("users").document(postOwner).collection("posts").document(postID).collection("ratings").whereField(FirebaseManager.shared.getCurrentUserID(), isEqualTo: userID)
//        
//        var ratingExists: Bool = false
//        
//        query.getDocuments { (document, error) in
//            if let error = error {
//                print("Error getting document: \(error.localizedDescription)")
//                ratingExists = false // Assuming an error means we can't confirm existence
//                return
//            }
//            
//            guard let snapshot = document else {
//                print("Document snapshot is nil")
//                ratingExists = false
//                return
//            }
//            
//            if snapshot.isEmpty {
//                print("snapshot is empty / no rating: \(snapshot.documents)")
//                ratingExists = false
//            } else {
//                print("rating should exist")
//                ratingExists = true
//            }
//        }
//        
//        return ratingExists
//    }
    
    func addRatingIDToUser(ratingID: String) {
        let uid = getCurrentUserID()
        let userRef = fs.collection("users").document(uid)
        userRef.updateData(["ratedPosts": FieldValue.arrayUnion([ratingID])])
    }
    
    func addPostToRated(postID: String) {
        let uid = getCurrentUserID()
        let userRef = fs.collection("users").document(uid)
        userRef.updateData(["ratedPosts": FieldValue.arrayUnion([postID])])
    }
    
    // **  below relates to photo selector  ** //
    
    // async function to upload imagedata to firebase storage with the uuid as the file name (needs rework)
    func uploadImage(uuidArray: [String], data: [Data]) async throws {
        print("attempting upload...")
        
        var imageIndex: Int = 0
        for imageData in data {
            let fileName = uuidArray[imageIndex]
            let storageRef = FirebaseManager.shared.storage.reference().child(fileName)
            
            imageIndex += 1
            
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("upload error")
                } else {
                    print("upload successful")
                }
            }
        }
    }
    
    func getImagesByUUID(uuids: [String]) async throws -> [UIImage] {
        // boiler plate func
        var images: [UIImage] = []
        let storageRef = FirebaseManager.shared.storage.reference()
        
        for id in uuids {
            let uuidRef = storageRef.child(id)
            print(uuidRef)
            let fileSize: Int64 = try await getFileSize(ref: uuidRef)
            let data = try await downloadData(ref: uuidRef, size: fileSize)
            
            if let image = UIImage(data: data) {
                images.append(image)
            }
        }
        
        return images
    }
    
    // gets file size in async before download, dont really know if this is correct or works 100%
    func getFileSize(ref: StorageReference) async throws -> Int64 {
        let metadata = try await ref.getMetadata()
        return metadata.size
    }
    
    // downloads data from storage ref and file size
    func downloadData(ref: StorageReference, size: Int64) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            // download limit is a problem when exceeded, default is 5MB but needs to be adaptable
            // set max size to size of image, making it dynamic
            ref.getData(maxSize: size) { data, error in
                if let error = error {
                    print("get data error: \(error)")
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
        }
    }
}
