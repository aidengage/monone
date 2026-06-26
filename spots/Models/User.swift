//
//  User.swift
//  spots
//
//  Created by Aiden Gage on 1/13/26.
//
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

// codable user object to send to firebase database
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let username: String
    let pfpUrl: String?
    var bookmarkedPostIds: [String] // remove
    var followers: [String] // remove
    var following: [String] // remove

    init(id: String, email: String, username: String, pfpUrl: String, bookmarkedPostIds: [String] = [], followers: [String] = [], following: [String] = []) {
        self.id = id
        self.email = email
        self.username = username
        self.pfpUrl = pfpUrl
        self.bookmarkedPostIds = bookmarkedPostIds
        self.followers = followers
        self.following = following
    }
    
//    init(user: FirebaseAuth.User?) {
//        self.id =
//    }
}

// remove
//extension Firebase {
//    func getCurrentUserID() -> String {
//        let currentUser = getAuth().currentUser
//        let userID = currentUser?.uid ?? ""
//        return userID
//    }
    
//    func logout() {
//        do {
//            try Auth.auth().signOut()
//        } catch {
//            print("Error signing out: \(error.localizedDescription)")
//        }
//    }
    
//    func getCurrentUser() -> FirebaseAuth.User? {
//        if Auth.auth().currentUser != nil {
//            //            let user = User(user: Auth.auth().currentUser)
//            return Auth.auth().currentUser
//        } else {
//            print("no current user")
//            return nil
//        }
//    }
    
//    func fetchUsername(userId: String) async -> String? {
//        guard !userId.isEmpty else { return nil }
//        do {
//            let snapshot = try await getStore().collection("users").document(userId).getDocument()
//
//            if let data = snapshot.data(),
//               let name = data["username"] as? String {
//                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
//                if !trimmed.isEmpty { return trimmed }
//            }
//
//            if let user = try? snapshot.data(as: User.self) {
//                let trimmed = user.username.trimmingCharacters(in: .whitespacesAndNewlines)
//                if !trimmed.isEmpty { return trimmed }
//            }
//
//            return nil
//        } catch {
//            print("fetchUsername error for \(userId): \(error)")
//            return nil
//        }
//    }
    
//    func addUser(uid: String, email: String, username: String, pfpUrl: String, bookmarkedPostIds: [String] = [], followers: [String] = [], following: [String] = []) {
//        let newUser = User(id: uid, email: email, username: username, pfpUrl: pfpUrl, bookmarkedPostIds: bookmarkedPostIds, followers: followers, following: following)
//        do {
//            let userRef = getStore().collection("users").document(uid)
//            try userRef.setData(from: newUser) { error in
//                if let error = error {
//                    print(error)
//                } else {
//                    userRef.updateData(["createdAt": FieldValue.serverTimestamp()])
//                    print("user added")
//                }
//            }
//        } catch {
//            print("error creating doc: \(error.localizedDescription)")
//        }
//    }
//}
