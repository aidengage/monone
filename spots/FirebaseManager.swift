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
    
    // async function to upload imagedata to firebase storage
    func uploadImage(data: [Data]) async throws {
        print("attempting upload...")
//        let storageRef = Storage.storage().reference()
        for imageData in data {
//            storageRef.child("\(UUID().uuidString)")
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
            let storageRef = Storage.storage().reference().child("\(UUID().uuidString)")
//            storageRef.putData(data, metadata: nil) { (metadata, error) in
            // metadata doesnt seem to be working rn
//            guard let metadata = metadata else {
//                return
//            }
//            if error != nil {
//                print("upload error")
//            } else {
//                print("upload successful")
//            }
//        }
//    }
}

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
//            if let data = data, let image = UIImage(data: data) {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame( maxHeight: 300)
//            } else {
//                Label("Select a picture", systemImage: "photo.on.rectangle.angled")
//            }
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
//            guard let item = selectedItem.first else {
//                return
//            }
//            item.loadTransferable(type: Data.self) { result in
//                switch result {
//                case .success(let data):
//                    if let data = data {
//                        self.data = data
//                        
//                    }
//                case .failure(let failure):
//                    print("Error: \(failure.localizedDescription)")
//                }
//            }
            
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

