//
//  ContentView.swift
//  spots
//
//  Created by Aiden Gage on 12/21/25
//  Contributions by Minahil starting 01/04/26

// many things happen in this file beware

import SwiftUI
import MapKit
import FirebaseAuth

struct ContentView: View {
    // initializing all these variables for the main map view to work
    
    // coords for center of the screen, sent to addpost view to autofill
    @State var centerLat: Double
    @State var centerLong: Double
    @State private var posts: [PostMan] = []
    //tracks which post is selected
    @State private var selectedPost: PostMan? = nil
    
    // boolean variables set to show login or add post page for conditional
    // probably dont need this many
    @State private var showAddPost = false
    @State private var showLogin = false
    
    // part of the navigation stack in body, appending to the end of this will send user to that page
    @State var path = NavigationPath()
    
    // setting camera position
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 38.25, longitude: -85.75),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottomLeading) {
                ZStack {
                    Map(position: $cameraPosition) {
                        // looping through posts array and displaying them all on map with a clickable marker
                        ForEach(posts.filter { $0.coords.0 != 0.0 && $0.coords.1 != 0.0 }) { post in
                            Annotation(post.title, coordinate: CLLocationCoordinate2D(latitude: post.coords.0, longitude: post.coords.1)) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                                .background(Color.white)
                                .clipShape(Circle())
                                .onTapGesture {
                                    // once user taps, state of selectedPost changes
                                    selectedPost = post
                                }
                            }
                        }
                    }
                    // loads posts when the map appears
                    .onAppear {
                        loadPosts()
                    }
                    // when map camera changes, update center coords with new center
                    .onMapCameraChange { mapCameraUpdateContext in
                        centerLat = mapCameraUpdateContext.camera.centerCoordinate.latitude
                        centerLong = mapCameraUpdateContext.camera.centerCoordinate.longitude
                        print("\(centerLat): \(centerLong)")
                    }
                    // visual indicator of the center of the screen
                    Image(systemName: "mappin")
                        .offset(y: -15)
                        .font(.system(size: 33))
                }

                // add post button
                Button(action: {
                    let currentUser = Auth.auth().currentUser
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // creates a toolbar to logout of account
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
            //once state of selectedPost changes, PostDetailView with post is launched. 
            .sheet(item: $selectedPost) { post in
                NavigationView {
                    PostDetailView(post: post)
                }
            }
        }
    }
    
    // uses firebasemanager getposts with the completion below
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
    
    // logout function
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
    fm.getDocs()
}


#Preview {
    ContentView(centerLat: 0.0, centerLong: 0.0)
}

