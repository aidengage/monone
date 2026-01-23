//
//  AddButton.swift
//  spots
//
//  Created by Aiden Gage on 1/22/26.
//
import SwiftUI
import FirebaseAuth


struct AddButton: View {
    
    @State private var showAddPost = false
    @State private var showLogin = false
    
    @Binding var path: NavigationPath
    
    @Binding var centerLat: Double
    @Binding var centerLong: Double
    
    var body: some View {
        Button(action: {
            let currentUser = Firebase.shared.getCurrentUser()
            print("Current user: \(currentUser?.email ?? "nil")")
            print("User ID: \(currentUser?.uid ?? "nil")")
            
            // when logged in, showAddPost is true, appends to path stack with variable
            if currentUser != nil {
                showAddPost = true
                path.append(showAddPost)
            } else {
                showLogin = true
                path.append(showLogin)
            }
        }) {
            Image(systemName: "plus")
                .font(.largeTitle)
                .padding(10)
        }
        .buttonStyle(.glass(.clear))
        .buttonBorderShape(.circle)
        .padding(.leading, 30)
        
        // navigation logic for login and addpost, sending center coords with the navigation
        .navigationDestination(isPresented: $showAddPost) {
            AddPostView(centerLat: centerLat, centerLong: centerLong)
        }
        .navigationDestination(isPresented: $showLogin) {
            LoginView()
        }
    }
}
