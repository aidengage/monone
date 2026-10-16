//
//  FeedbackService.swift
//  spots
//
//  Created by Aiden Gage on 6/25/26.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

protocol feedbackServiceProtocol {
    func submitFeedback(message: String, feedbackType: FeedbackType, screenshots: [UIImage]) async throws
//    func uploadFeedbackScreenshot(screenshot: UIImage, path: String, format: ImageFormat) async throws -> String
//    func smartFormat(image: UIImage, path: String) async throws -> String
    func deleteFeedbackBatch(feedbackId: String) async
    func deleteFeedback(feedbackId: String) async
    func deleteScreenshots(feedbackId: String) async
}

@Observable
class FeedbackService: feedbackServiceProtocol {
    private let authService: authServiceProtocol
    private let dbService: dbServiceProtocol
    private let storageService: storageServiceProtocol
    
    private let imageService: imageServiceProtocol
    
    init(authService: authServiceProtocol, dbService: dbServiceProtocol, storageService: storageServiceProtocol, imageService: imageServiceProtocol) {
        self.authService = authService
        self.dbService = dbService
        self.storageService = storageService
        self.imageService = imageService
    }
    
    
    
    
    
    func submitFeedback(message: String, feedbackType: FeedbackType, screenshots: [UIImage]) async throws {
        let deviceModel = UIDevice.current.model + " (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))"
        let osVersion = UIDevice.current.systemVersion
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        
        let userId = try await authService.getCurrentUserID()
        let userEmail = /*try await*/ authService.getCurrentUser()?.email
        
        let feedbackId = UUID().uuidString
        
        var screenshotUrls: [String] = []
        if !screenshots.isEmpty {
            for (index, screenshot) in screenshots.enumerated() {
                let path = "feedback/\(feedbackId)/screenshot_\(index)"
//                let url = try await uploadFeedbackScreenshot(screenshot: screenshot, path: path, format: .png)
                let url = try await imageService.smartFormat(image: screenshot, path: path)
                screenshotUrls.append(url)
            }
        }
        
        let feedbackRef = dbService.getStore().collection("feedback").document(feedbackId)
        
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
            status: .open
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
    
        
    func deleteFeedbackBatch(feedbackId: String) async {
        await deleteFeedback(feedbackId: feedbackId)
        await deleteScreenshots(feedbackId: feedbackId)
    }
    
    func deleteFeedback(feedbackId: String) async {
        do {
//            let feedbackRef = try await getStore().collection("feedback").document(feedbackId).getDocument()
            let batch = dbService.getStore().batch()
            batch.deleteDocument(dbService.getStore().collection("feedback").document(feedbackId))
            try await batch.commit()
            
            
        } catch {
            print(" deleting feedback: ")
        }
    }
    
    func deleteScreenshots(feedbackId: String) async {
        do {
            let scUrls: [String] = try await dbService.getStore().collection("feedback").document(feedbackId).getDocument()["screenshotUrls"] as? [String] ?? []
            for url in scUrls {
                try await storageService.getStorage().reference(forURL: url).delete()
            }
        } catch {
            
        }
    }
}
