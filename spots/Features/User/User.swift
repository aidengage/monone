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

// codable user obejct to send to firebase database
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let username: String
    let pfpUrl: String?
}

// not used yet but will be when we get user accounts
struct UserMan {
    let userId: String
    let email: String
    let username: String
    let pfpUrl: String
    
    init(userId: String, email: String, username: String, pfpUrl: String) {
        self.userId = userId
        self.email = email
        self.username = username
        self.pfpUrl = pfpUrl
    }
}

extension Firebase {
    func getCurrentUserID() -> String {
        let currentUser = getAuth().currentUser
        let userID = currentUser?.uid ?? ""
        return userID
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func getCurrentUser() -> FirebaseAuth.User? {
        if Auth.auth().currentUser != nil {
            return Auth.auth().currentUser
        } else {
            print("no current user")
            return nil
        }
    }
    
    func addUser(uid: String, email: String, username: String) {
        let newUser = User(id: uid, email: email, username: username, pfpUrl: "")
        do {
            let userRef = getStore().collection("users").document(uid)
            try userRef.setData(from: newUser) { error in
                if let error = error {
                    print(error)
                } else {
                    // test this
                    userRef.updateData(["createdAt": FieldValue.serverTimestamp()])
                    print("user added")
                }
            }
        } catch {
            print("error creating doc: \(error.localizedDescription)")
        }
    }
}
