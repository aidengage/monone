//
//  storageService.swift
//  spots
//
//  Created by Aiden Gage on 6/25/26.
//

import SwiftUI
import FirebaseStorage

protocol storageServiceProtocol {
    func getStorage() -> Storage
    func uploadImage(uuidArray: [String], data: [Data]) async throws
    func getImagesByUUID(uuids: [String]) async throws -> [UIImage]
    func getImageURLs(uuids: [String]) -> [URL]
    func getFileSize(ref: StorageReference) async throws -> Int64
    func downloadData(ref: StorageReference, size: Int64) async throws -> Data
    func uploadFeedbackScreenshot(screenshot: UIImage, path: String, format: ImageFormat) async throws -> String
}

@Observable
class storageService: storageServiceProtocol {
    private let storage = Storage.storage()
    
    func getStorage() -> Storage {
        return storage
    }
    
    // async function to upload imagedata to firebase storage with the uuid as the file name (needs rework)
    func uploadImage(uuidArray: [String], data: [Data]) async throws {
        print("attempting upload...")
        
        var imageIndex: Int = 0
        for imageData in data {
            let fileName = uuidArray[imageIndex]
//            let storageRef = Firebase.shared.storage.reference().child(fileName)
            let storageRef = getStorage().reference().child(fileName)
            
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
        let storageRef = getStorage().reference()
        
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
    
    func uploadFeedbackScreenshot(screenshot: UIImage, path: String, format: ImageFormat) async throws -> String {
        let imageData: Data?
        let contentType: String
        
        switch format {
        case .png:
            imageData = screenshot.pngData()
            contentType = "image/png"
            
        case .jpeg(let quality):
            imageData = screenshot.jpegData(compressionQuality: quality)
            contentType = "image/jpeg"
            
        case .heic:
            if #available(iOS 17.0, *){
                imageData = screenshot.heicData()
                contentType = "image/heic"
            } else {
                imageData = screenshot.jpegData(compressionQuality: 0.7)
                contentType = "image/jpeg"
            }
        }
        
        guard let imageData = imageData else {
            print("image failed to compress")
            return "shit broke"
        }
        
        let storageRef = storage.reference().child(path + format.fileExtension)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadUrl = try await storageRef.downloadURL()
        print("download url: \(downloadUrl.absoluteString)")
        
        return downloadUrl.absoluteString
    }

}
