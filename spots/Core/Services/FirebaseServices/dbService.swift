//
//  dbService.swift
//  spots
//
//  Created by Aiden Gage on 6/25/26.
//

import SwiftUI
import FirebaseFirestore

protocol dbServiceProtocol {
    func getDB() -> Firestore
}

@Observable
class dbService: dbServiceProtocol {
    private let db = Firestore.firestore()
    
    func getDB() -> Firestore {
        return db
    }
    
    func stopPostListener() {
        postListener?.remove()
        postListener = nil
    }
    
    func stopRatingListener() {
        ratingListener?.remove()
        ratingListener = nil
    }
    
    func stopFeedbackListener() {
        feedbackListener?.remove()
        feedbackListener = nil
    }
    
    func docUpdatedAt(docRef: DocumentReference) async {
        do {
            try await docRef.updateData(["updatedAt": FieldValue.serverTimestamp()])
        } catch {
            print("error updating at...")
            print(error.localizedDescription)
        }
    }
    
    func addUser(uid: String, email: String, username: String, pfpUrl: String, bookmarkedPostIds: [String] = [], followers: [String] = [], following: [String] = []) {
        let newUser = User(id: uid, email: email, username: username, pfpUrl: pfpUrl, bookmarkedPostIds: bookmarkedPostIds, followers: followers, following: following)
        do {
            let userRef = db.collection("users").document(uid)
            try userRef.setData(from: newUser) { error in
                if let error = error {
                    print(error)
                } else {
                    userRef.updateData(["createdAt": FieldValue.serverTimestamp()])
                    print("user added")
                }
            }
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
    }
    
    func addUserFromGoogle(user: FirebaseAuth.User, gProfile: GIDProfileData?) {
        
        let uid = user.uid
        let email = user.email ?? gProfile?.email ?? ""
        let username = user.displayName ?? gProfile?.name ?? ""
        let pfpURL = user.photoURL ?? gProfile?.imageURL(withDimension: 200)
        
        if !uid.isEmpty && !email.isEmpty && !username.isEmpty {
            Firebase.shared.addUser(uid: uid, email: email, username: username, pfpUrl: pfpURL?.absoluteString ?? "", bookmarkedPostIds: [], followers: [], following: [])
        } else {
            print("uid or email or username empty")
        }
        
    }
    
    func addUserFromApple() {
        
    }
    
    // post listeners
    func startPostListenerById(postId: String) {
        Firebase.shared.stopPostListener()

        Firebase.shared.postListener = Firebase.shared.getStore().collection("posts").document(postId).addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error getting post: \(error.localizedDescription)")
                return
            }

            guard let document = snapshot else {
                print("No post found")
                return
            }

            do {
                self.post = try document.data(as: Post.self)
            } catch {
                print("error decoding post (\(postId)): \(error.localizedDescription)")
                print("because it was deleted")
            }
        }
//        print("starting single post listener")
    }
    
    func startUserPostListener(userId: String) {
        stopPostListener()
        
        postListener = getStore().collection("posts").whereField("userId", isEqualTo: userId).addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting posts: \(error)")
                return
            }
                
            guard let documents = snapshot?.documents else {
                print("no user posts found")
                self.posts = []
                return
            }
                
            self.posts = documents.compactMap { document in
                do {
                    let post = try document.data(as: Post.self)
                    return post
                } catch {
                    print("error finding user (\(userId) documents: \(error)")
                    return nil
                }
            }
        }
//        print("starting user post listener")
    }

    
    func startPostListener() {
        stopPostListener()
        
        postListener = getStore().collection("posts").addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting posts: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No posts found")
                self.posts = []
                return
            }
            
//            print("inside postlistener: \(documents.count)")
            
            self.posts = documents.compactMap { document in
                do {
                    let post = try document.data(as: Post.self)
                    return post
                } catch {
                    print("Error decoding document \(document.documentID): \(error)")
                    return nil
                }
            }
        }
//        print("starting post listener")
//        print("post class listerner count: \(self.posts.count)")
    }
    
    func startPostActivityListener(activity: ActivityType) {
        stopPostListener()
//        print("activity: \(activity)")
//        print("display activity: \(activity.displayActivity)")
        postListener = getStore().collection("posts")
            .whereField("selectedActivity", isEqualTo: activity.displayActivity)
            .addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting posts: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No posts found")
                self.posts = []
                return
            }
                
            self.posts = documents.compactMap { document in
                do {
                    let post = try document.data(as: Post.self)
                    return post
                } catch {
                    print("Error decoding document \(document.documentID): \(error)")
                    return nil
                }
            }
        }
    }
    
    func startRatingListener(postId: String) {
        stopRatingListener()
        
        ratingListener = getStore().collection("ratings")
            .whereField("postId", isEqualTo: postId)
            .addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("error getting ratings: \(error.localizedDescription)")
            }
            
            guard let documents = snapshot?.documents else {
                print("No ratings found")
                self.ratings = []
                return
            }
            
            self.ratings = documents.compactMap { document in
                do {
                    let rating = try document.data(as: Rating.self)
                    return rating
                } catch {
                    print("error decoding rating \(document.documentID): \(error.localizedDescription)")
                    return nil
                }
            }
        }
        print("rating count in post: \(self.ratings.count)")
    }
    
    func startFeedbackListener(userId: String) {
        Firebase.shared.stopFeedbackListener()
        
        if getCurrentUser() != nil {
            
            Firebase.shared.feedbackListener = Firebase.shared.getStore().collection("feedback")
                .whereField("userId", isEqualTo: userId)
                .addSnapshotListener { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error getting feedback: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No feedbacks found")
                    self.feedbacks = []
                    return
                }
                
                self.feedbacks = documents.compactMap { document in
                    do {
                        let feedback = try document.data(as: Feedback.self)
                        return feedback
                    } catch {
                        print("Error decoding feedback \(document.documentID): \(error)")
                        return nil
                    }
                }
            }
            
            //        print("starting user feedback listener")
        } else {
            print("           need to sign in")
        }

    }

    
    
    
}
