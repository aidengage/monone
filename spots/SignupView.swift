//
//  Signupview.swift
//  spots
//
//  Created by Minahil on 1/5/26.
//

import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @Environment(\.dismiss)private var dismiss
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var error: String? = nil

    var body: some View {
        
        // signup form for user to fill out to create an account
        Form {
            Section(header: Text("Email")) {
                TextField("Email", text: $email)
                TextField("Username (optional)", text: $username)
            }
            Section(header: Text("Password")) {
                TextField("Password", text: $password)
            }
            Section(header: Text("Confirm Password")) {
                TextField("Confirm Password", text: $confirmPassword)
            }
            Button(action: {
                signup(email: email, username: username, password: password)
            }) {
                Text("Signup")
            }
        }
        .navigationTitle("Sign Up")

    }
    
    // signup function to create account linked to button
    func signup(email: String, username: String, password: String) {
        if password != confirmPassword {
            error = "Passwords do not match"
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                
                guard let user = authResult?.user else {
                    self.error = "Could not create user"
                    return
                }
                
                let uid = user.uid
                
                if let error = error {
                    print(error)
                } else {
                    print("User created successfully")
                    FirebaseManager.shared.addUser(uid: uid, email: email, username: username, posts: [])
                    dismiss()
                }
            }
        }
    }
}
