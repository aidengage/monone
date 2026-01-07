//
//  Signupview.swift
//  spots
//
//  Created by Minahil on 1/5/26.
//

import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var error: String? = nil
    @Environment(\.dismiss)private var dismiss

    var body: some View {
        Form {
            Section(header: Text("Email")) {
                TextField("Email", text: $email)
            }
            Section(header: Text("Password")) {
                TextField("Password", text: $password)
            }
            Section(header: Text("Confirm Password")) {
                TextField("Confirm Password", text: $confirmPassword)
            }
            Button(action: {
                signup(email: email, password: password)
            }) {
                Text("Signup")
            }
        }
        .navigationTitle("Sign Up")

    }
    
    func signup(email: String, password: String) {
        if password != confirmPassword {
            error = "Passwords do not match"
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print(error)
                } else {
                    print("User created successfully")
                    dismiss()
                }
            }
        }
    }
}
