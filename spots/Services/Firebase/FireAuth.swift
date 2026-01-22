//
//  FireAuth.swift
//  spots
//
//  Created by Aiden Gage on 1/20/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

final class FireAuth {
    func getCurrentUserID() -> String {
        let currentUser = Auth.auth().currentUser
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
}
