//
//  Signupview.swift
//  spots
//
//  Created by Minahil on 1/5/26.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

struct SignupView: View {
    @Environment(\.dismiss)private var dismiss
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var error: String? = nil
    @State private var selectedPhoto: [PhotosPickerItem] = []
//    @State private var selectedImage: [UIImage] = []
    @State private var profileImage: UIImage?

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
            
            // upload profile picture needs square crop
            Section(header: Text("Upload a Profile Picture")) {
                ProfilePhotoSelectorView(image: $profileImage)
            }
            
            Button(action: {
                Task {
                    await signup(email: email, username: username, password: password)
                }
            }) {
                Text("Signup")
            }
            .buttonStyle(.glassProminent)
        }
        .navigationTitle("Sign Up")

    }

    
    
    func uploadPfp(userId: String, photo: UIImage) async {
        do {
            if profileImage != nil {
                let path = "users/\(userId)/\(userId)"
                let url = try await Firebase.shared.smartFormat(image: photo, path: path)
                try await Firebase.shared.getStore().collection("users").document(userId).updateData(["pfpUrl": url])
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
        
    }
    
    // signup function to create account linked to button
    func signup(email: String, username: String, password: String) async {
        do {
            if password != confirmPassword {
                error = "Passwords do not match"
            } else {
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                
                // setting user id
                let uid = authResult.user.uid
                
                if let error = error {
                    print(error)
                } else {
                    // creates corresponding user in firebase db to link to
                    print("auth created, adding user and uploading pfp")
                    
                    Task {
                        Firebase.shared.addUser(uid: uid, email: email, username: username)
                        await uploadPfp(userId: uid, photo: profileImage!)
                    }
                    
                    dismiss()
                }
            }
        } catch {
            print("error : \(error.localizedDescription)")
        }
    }
}
