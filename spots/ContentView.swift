//
//  ContentView.swift
//  spots
//
//  Created by Aiden Gage on 12/21/25
//  Contributions by Minahil starting 01/04/26

import SwiftUI
import MapKit
import FirebaseAuth

struct ContentView: View {
    @State private var posts: [PostMan] = []
    //tracks which post is selected
    @State private var selectedPost: PostMan? = nil
    @State private var showAddPost = false
    @State private var showLogin = false
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 38.25, longitude: -85.75),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition) {
                    ForEach(posts.filter { $0.coords.0 != 0.0 && $0.coords.1 != 0.0 }) { post in
                        Annotation(post.title, coordinate: CLLocationCoordinate2D(latitude: post.coords.0, longitude: post.coords.1)) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                                .background(Color.white)
                                .clipShape(Circle())
                                .onTapGesture {
//                                    once user taps, state of selectedPost changes
                                    selectedPost = post
                                }
                        }
                    }
                }
                .ignoresSafeArea(.all)
                .onAppear {
                    loadPosts()
                }
                
                Button(action: {
                    let currentUser = Auth.auth().currentUser
                    print("Current user: \(currentUser?.email ?? "nil")")
                    print("User ID: \(currentUser?.uid ?? "nil")")
                    
                    if currentUser != nil {
                        showAddPost = true
                    } else {
                        showLogin = true
                    }
                }) {
                    Label("Add Post", systemImage: "mappin")
                }
                .buttonStyle(.glass(.clear))
                .glassEffect()
                .sheet(isPresented: $showAddPost) {
                    NavigationView {
                        AddPostView()
                    }
                }
                .sheet(isPresented: $showLogin) {
                    NavigationView {
                        LoginView()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if Auth.auth().currentUser != nil {
                        Button(action: {
                            logout()
                        }) {
                            Label("Logout", systemImage: "arrow.right.square")
                        }
                    }
                }
            }
            //once state of selectedPost changes, PostDetailView is launched. 
            .sheet(item: $selectedPost) { post in
                NavigationView {
                    PostDetailView(post: post)
                }
            }
        }
    }
    
    func loadPosts() {
        fm.getPosts(completion: handleLoadedPosts)
    }
    
    //this completion handler is triggered once the posts are loaded, and it updates the posts state variable because there is a state change in the posts variable (going from empty to having data)
    func handleLoadedPosts(loadedPosts: [PostMan]) {
        print("\(loadedPosts.count) posts from Firebase")
        for (index, post) in loadedPosts.enumerated() {
            print("   Post \(index + 1): \(post.title) - Coords: (\(post.coords.0), \(post.coords.1))")
        }
        posts = loadedPosts
        print("Updated posts state variable. Map will now render markers.")
    }
    
    func logout() {
        print("🚪 Logout button tapped")
        do {
            try Auth.auth().signOut()
            print("Successfully signed out")
        } catch {
            print("Error signing out")
        }
    }
}

let fm = FirebaseManager()

func getDocs() {
//    fm.printDocs()
    fm.getDocs()
}


#Preview {
    ContentView()
}

