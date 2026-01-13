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
//    @DocumentID var id: String?
    var images: [String?]
    var name: String?
    var address: String?
    var rating: Double?
    var description: String?
//    var location: (Double?, Double?)
    var xLoc: Double?
    var yLoc: Double?
}

// codable user obejct to send to firebase database
struct User: Codable {
    var uid: String?
    var email: String?
    var username: String?
    var posts: [Post]
}

// photo selector view, maybe move this to add post view??
struct PhotoSelector: View {
    @Binding var data: [Data]
    @Binding var imageUUIDs: [String]
    @State var selectedItem: [PhotosPickerItem] = []

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images, preferredItemEncoding: .automatic) {
            if !data.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(data, id: \.self) { imageData in
                            if let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame( maxHeight: 300)
                            }
                        }
                    }
                }
            } else {
                Label("Select a picture", systemImage: "photo.on.rectangle.angled")
            }
        }.onChange (of: selectedItem) {_, newValue in
            for item in selectedItem {
                Task {
                    if let imageData = try? await item.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            // add uuid to own array
                            imageUUIDs.append(UUID().uuidString)
                            data.append(imageData)
                        }
                    }
                }
            }
        }
    }
}


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
    func addUser(uid: String, email: String, username: String, posts: [Post]) {
        let newUser = User(uid: uid, email: email, username: username, posts: posts)
        do {
            try fs.collection("users").addDocument(from: newUser) { error in
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
    
    func getCurrentUserID() -> String {
        let currentUser = Auth.auth().currentUser
        let userID = currentUser?.uid ?? ""
        return userID
    }
    
    
    // **  below is post database querying, currently reworking for users and posts  ** //
    
    // queries the "post" collection, getting every doc and storing them in a document dictionary
    // and prints everything in the dictionary (i dont think we need the above print function anymore then)
    func getDocs() {
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
    
    // get posts function queries "post" collection and sets all the data to its corresponding post values
    func getPosts(completion: @escaping ([PostMan]) -> Void) {
        var postArray: [PostMan] = []
        fs.collection("post").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("error getting posts: \(error)")
                completion([])
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    // setting all data
                    let title = data["name"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let images = data["images"] as? [String] ?? []
                    let address = data["address"] as? String ?? ""
                    
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
                        title: title,
                        description: description,
                        images: images,
                        coords: (xLoc, yLoc),
                        address: address
                    )
                    
                    // stores to the postArray
                    postArray.append(post)
                }
                //this completion handler triggers handleLoadedPosts method in ContentView.swift and its only triggered once the posts are loaded                
                completion(postArray)
            }
        }
    }
    
    // creates post with these params and adds to the "post" collection
    func addPost(images: [String], name: String, address: String, rating: Double, description: String, coords: (xLoc: Double, yLoc: Double)) {
        let newPost = Post(images: images, name: name, address: address, rating: rating, description: description, xLoc: coords.xLoc, yLoc: coords.yLoc)
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
    
    
    // **  below relates to photo selector  ** //
    
    // async function to upload imagedata to firebase storage with the uuid as the file name (needs rework)
    func uploadImage(uuidArray: [String], data: [Data]) async throws {
        print("attempting upload...")
        
        var imageIndex: Int = 0
        for imageData in data /*&& index in uuidArray*/ {
            let fileName = uuidArray[imageIndex]
//            print("index: \(imageIndex), uuid: \(fileName)")
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
//        let storageRef = Storage.storage().reference()//.child("images/")
        
        for id in uuids {
//            let uuidRef = Storage.storage().reference(withPath: id)
            let uuidRef = storageRef.child(id)
            print(uuidRef)
            
//            let data = try await uuidRef.getData(maxSize: 5 * 1024 * 1024)
            let data = try await downloadData(ref: uuidRef)
            if let image = UIImage(data: data) {
                images.append(image)
            }
        }
        
        return images
    }
    
    func downloadData(ref: StorageReference) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error = error {
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
