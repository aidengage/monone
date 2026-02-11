//
//  Feedback.swift
//  spots
//
//  Created by Aiden Gage on 2/8/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct Feedback: Codable, Identifiable {
    let id: String
    let userId: String
    let email: String
    let message: String
//    let createdAt: Date
    let screenshotUrls: [String]?
    
    let deviceModel: String
    let osVersion: String
    let appVersion: String
    let appBuild: String
    
    let feedbackType: FeedbackType
//    let status: FeedbackStatus
}

enum FeedbackType: String, Codable {
    case bug = "bug"
    case improvement = "improvement"
    case feature = "feature"
    case general = "general"
    case complaint = "complaint"
}

enum FeedbackStatus: String, Codable {
    case open = "open"
    case resolved = "resolved"
    case archived = "archived"
    case duplicate = "duplicate"
}

extension Firebase {
    
    func submitFeedback(message: String, feedbackType: FeedbackType, screenshots: [UIImage]) async throws {
        let deviceModel = UIDevice.current.model + " (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))"
        let osVersion = UIDevice.current.systemVersion
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        
        let userId = getCurrentUserID()
        let userEmail = getCurrentUser()?.email
        
        let feedbackId = UUID().uuidString
        
        var screenshotUrls: [String] = []
        if !screenshots.isEmpty {
            for (index, screenshot) in screenshots.enumerated() {
                let path = "feedback/\(feedbackId)/screenshot_\(index)"
//                let url = try await uploadFeedbackScreenshot(screenshot: screenshot, path: path, format: .png)
                let url = try await smartFormat(image: screenshot, path: path)
                screenshotUrls.append(url)
            }
        }
        
        let feedbackRef = getStore().collection("feedback").document(feedbackId)
        
        let newFeedback = Feedback(
            id: feedbackId,
            userId: userId,
            email: userEmail ?? "unknown",
            message: message,
//            createdAt: FieldValue.ServerTimestamp(),
            screenshotUrls: screenshotUrls.isEmpty ? [] : screenshotUrls,
            deviceModel: deviceModel,
            osVersion: osVersion,
            appVersion: appVersion,
            appBuild: appBuild,
            feedbackType: feedbackType,
//            status: .open
        )
        
        try feedbackRef.setData(from: newFeedback) { error in
            if let error = error {
                print("error adding feedback: \(error)")
            } else {
                feedbackRef.updateData(["createdAt": FieldValue.serverTimestamp()])
                print("feedback added??")
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
                imageData = screenshot.jpegData(compressionQuality: 0.8)
                contentType = "image/jpeg"
            }
        }
        
        guard let imageData = imageData else {
            print("image failed to compress")
            return "shit broke"
        }
        
        let storageRef = getStorage().reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadUrl = try await storageRef.downloadURL()
        print("download url: \(downloadUrl.absoluteString)")
        
        return downloadUrl.absoluteString
    }
    
    func smartFormat(image: UIImage, path: String) async throws -> String {
        let hasAlpha = image.cgImage?.alphaInfo != CGImageAlphaInfo.none
        let format: ImageFormat
        
        if hasAlpha {
            format = .png
        } else {
            format = .jpeg(compressionQuality: 0.8)
        }
        print("smart format is: \(format)")
        
        return try await uploadFeedbackScreenshot(screenshot: image, path: path, format: format)
    }
    
    func deleteScreenshotByUrl(feedbackId: String) async {
        do {
            let scUrls: [String] = try await getStore().collection("feedback").document(feedbackId).getDocument()["screenshotUrls"] as? [String] ?? []
            for url in scUrls {
                try await storage.storage.reference(forURL: url).delete()
            }
        } catch {
            
        }
    }
}
