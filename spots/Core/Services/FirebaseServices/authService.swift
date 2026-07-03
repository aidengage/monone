//
//  authService.swift
//  spots
//
//  Created by Aiden Gage on 6/25/26.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

protocol authServiceProtocol {
    func getAuth() -> Auth
    func getAuthStatus() -> Bool
    func getCurrentUserID() async throws -> String
    func getCurrentUser() -> FirebaseAuth.User?
    func signInWithGoogle(presenting: UIViewController) async throws -> GIDSignInResult
//    func signInWithApple()
    func logout()
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
    
    func getCurrentUser() -> FirebaseAuth.User? {
        if Auth.auth().currentUser != nil {
//            let user = User(user: Auth.auth().currentUser)
            return Auth.auth().currentUser
        } else {
            print("no current user")
            return nil
        }
    }
    
    func getCurrentUserID() async throws -> String {
        let user = auth.currentUser
        guard let uid = user?.uid else {
            throw authServiceError.notAuthenticated
        }
        
        return uid
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func signInWithGoogle(presenting: UIViewController) async throws -> GIDSignInResult {
        try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { signInResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = signInResult {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown sign-in error"]))
                }
            }
        }
    }
    
//    func signInWithApple() {
//        
//    }
}
