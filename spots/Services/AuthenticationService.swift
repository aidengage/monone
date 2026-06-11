//
//  AuthenticationService.swift
//  spots
//
//  Created by Aiden Gage on 6/9/26.
//
//  https://firebase.google.com/docs/auth/ios/google-signin
//  https://codelabs.developers.google.com/codelabs/sign-in-with-google-ios#4

import SwiftUI
import AuthenticationServices
import CryptoKit
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import UIKit

struct GoogleSignIn: View {
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
        
        // start sign in process
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            guard let result = signInResult else {
                // error handle
                print("error signing in: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            // if sign in worked
            print("id token: \(result.user.idToken?.tokenString ?? "no id token")")
        }
    }
}

struct AppleSignIn: View {
    
    var body: some View {
        
    }
}
