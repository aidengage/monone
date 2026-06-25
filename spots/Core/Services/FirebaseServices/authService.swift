//
//  authService.swift
//  spots
//
//  Created by Aiden Gage on 6/25/26.
//

import SwiftUI
import FirebaseAuth

protocol authServiceProtocol {
    func getAuth() -> Auth
    func getAuthStatus() -> Bool
    func getCurrentUserID() async throws -> String
}

enum authServiceError: Error {
    case notAuthenticated
    case couldNotFetchUserID
}

@Observable
class authService: authServiceProtocol {
    private let auth = Auth.auth()
    var currentUserID: String? { return auth.currentUser?.uid }
    
    func getAuth() -> Auth {
        return auth
    }
    
    func getAuthStatus() -> Bool {
        return auth.currentUser != nil
    }
    
    func getCurrentUserID() async throws -> String {
        let user = auth.currentUser
        guard let uid = user?.uid else {
            throw authServiceError.notAuthenticated
        }
        
        return uid
    }
}
