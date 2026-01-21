//
//  FireStorage.swift
//  spots
//
//  Created by Aiden Gage on 1/20/26.
//

import SwiftUI
import FirebaseCore
import FirebaseStorage

final class FireStorage {
    private let storage: Storage
    
    init() {
        let app = FirebaseApp.app()!
        storage = Storage.storage(app: app)
    }
    
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
    
    func getImageURLs(uuids: [String]) -> [URL] {
        var urls: [URL] = []
        for id in uuids {
            let url = "https://firebasestorage.googleapis.com/v0/b/monone-swift.firebasestorage.app/o/\(id)?alt=media"
            urls.append(URL(string: url)!)
        }
        
        return urls
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
