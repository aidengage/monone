//
//  AuthenticationService.swift
//  spots
//
//  Created by Aiden Gage on 6/9/26.
//
//  https://firebase.google.com/docs/auth/ios/google-signin
//  https://codelabs.developers.google.com/codelabs/sign-in-with-google-ios#4
//  https://www.createwithswift.com/sign-in-with-apple-on-a-swiftui-application/ we need developer account now for this actually


import SwiftUI
import AuthenticationServices
import CryptoKit
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import FirebaseFirestore
import UIKit

struct GoogleSignIn: View {
    @Environment(\.dismiss)private var dismiss
    
    private let dbService: dbServiceProtocol
    private let authService: authServiceProtocol
    
    init(authService: authServiceProtocol) {
        self.authService = authService
    }
    
    var body: some View {
        VStack {
            GoogleSignInButton(style: .standard, action: handleSignInButton)
                
        }
    }
    
    func handleSignInButton() {
        // find current window
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            print("there is no active window scene")
            return
        }
        
        // get root view controller
        guard let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?
            .rootViewController
        else {
            print("there is no key window or root view controller")
            return
        }
        
        Task {
            do {
                // start sign in process
                let result = try await authService.signInWithGoogle(presenting: rootViewController)
                
                guard let idToken = result.user.idToken?.tokenString else {
                    print("missing id token from google")
                    return
                }
                
                let accessToken = result.user.accessToken.tokenString
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                
                let authResult = try await Auth.auth().signIn(with: credential)
                let firebaseUser = authResult.user
                
                let exists = try await dbService.getDB()
                    .collection("users")
                    .document(firebaseUser.uid)
                    .getDocument()
                    .exists
                
                if !exists {
                    dbService.addUserFromGoogle(user: firebaseUser, gProfile: result.user.profile)
                }
                
                print("signed in????")
                dismiss()
            } catch {
                print("sign in failed :(")
            }
        }
    }
    
//    func signInWithGoogle(presenting: UIViewController) async throws -> GIDSignInResult {
//        try await withCheckedThrowingContinuation { continuation in
//            GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { signInResult, error in
//                if let error = error {
//                    continuation.resume(throwing: error)
//                } else if let result = signInResult {
//                    continuation.resume(returning: result)
//                } else {
//                    continuation.resume(throwing: NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown sign-in error"]))
//                }
//            }
//        }
//    }
}

//extension Firebase {
//    func addUserFromGoogle(user: FirebaseAuth.User, gProfile: GIDProfileData?) {
//        
//        let uid = user.uid
//        let email = user.email ?? gProfile?.email ?? ""
//        let username = user.displayName ?? gProfile?.name ?? ""
//        let pfpURL = user.photoURL ?? gProfile?.imageURL(withDimension: 200)
//        
//        if !uid.isEmpty && !email.isEmpty && !username.isEmpty {
//            Firebase.shared.addUser(uid: uid, email: email, username: username, pfpUrl: pfpURL?.absoluteString ?? "", bookmarkedPostIds: [], followers: [], following: [])
//        } else {
//            print("uid or email or username empty")
//        }
//        
//    }
//}

struct AppleSignIn: View {
    
    var body: some View {
        
    }
}
