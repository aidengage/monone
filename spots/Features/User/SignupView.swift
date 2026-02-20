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
    @State private var selectedImage: [UIImage] = []

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
                HStack {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        maxSelectionCount: 1,
                        matching: .images
                    ) {
                        Label("Add pfp", systemImage: "photo")
                    }
                    .onChange(of: selectedPhoto) {
                        Task {
                            await loadImage(items: selectedPhoto)
                        }
                    }
                    Spacer()
                    if !selectedImage.isEmpty {
                        ForEach(selectedImage.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImage[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Button {
                                    selectedImage.remove(at: index)
                                    selectedPhoto.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.6)))
                                }
                                .padding(4)
                            }
                        }
                    }
                }
            }
            
            Button(action: {
                Task {
                    await signup(email: email, username: username, password: password/*, photo: selectedImage*/)
//                    try await uploadPfp(userId: uid, photo: selectedImage)
                }
            }) {
                Text("Signup")
            }
            .buttonStyle(.glassProminent)
        }
        .navigationTitle("Sign Up")

    }

    
    
    func uploadPfp(userId: String, photo: [UIImage]) async {
        do {
            var imageUrl: [String] = []
            if !selectedImage.isEmpty {
                for photo in selectedImage {
                    let path = "users/\(userId)/\(userId)"
                    //                let url = try await uploadFeedbackScreenshot(screenshot: screenshot, path: path, format: .png)
                    let url = try await Firebase.shared.smartFormat(image: photo, path: path)
                    imageUrl.append(url)
                    try await Firebase.shared.getStore().collection("users").document(userId).updateData(["pfpUrl": imageUrl[0]])
                }
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
                        Firebase.shared.addUser(uid: uid, email: email, username: username/*, pfpUrl: imageUrl*/)
                        await uploadPfp(userId: uid, photo: selectedImage)
                    }
                    
                    dismiss()
                }
            }
        } catch {
            print("error : \(error.localizedDescription)")
        }
    }
    
    private func loadImage(items: [PhotosPickerItem]) async {
        selectedImage.removeAll()
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage.append(image)
            }
        }
    }
}
