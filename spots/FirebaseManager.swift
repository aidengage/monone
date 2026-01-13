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
        self.storage = Storage.storage()
        self.docDict = [:]
    }
    
    // queries the "post" collection in the database and prints out every post in "post"
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
                    
                    // creating post from set data with post manager (PostMan)
                    let post = PostMan(
                        docId: document.documentID,
                        title: title,
                        description: description,
                        image: image,
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
    
    // async function to upload imagedata to firebase storage with the uuid as the file name (needs rework)
    func uploadImage(data: [Data]) async throws {
        print("attempting upload...")
        
        for imageData in data {
            let storageRef = Storage.storage().reference().child("\(UUID().uuidString)")
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("upload error")
                } else {
                    print("upload successful")
                }
            }
        }
    }
}

// photo selector view, maybe move this to add post view??
struct PhotoSelector: View {
    @Binding var data: [Data]
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
                            data.append(imageData)
                        }
                    }
                }
            }
        }
    }
}
    
// codable post object to allow encoding data to send to firebase to to to to
// needs work
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

