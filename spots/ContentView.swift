//
//  ContentView.swift
//  spots
//
//  Created by Aiden Gage on 12/21/25
//  Contributions by Minahil starting 01/04/26


import SwiftUI
import MapKit

struct ContentView: View {
    @State private var posts: [PostMan] = []
    //tracks which post is selected
    @State private var selectedPost: PostMan? = nil
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
                
                    NavigationLink {
                        AddPostView()
                    } label: {
                        Label("Add Post", systemImage: "mappin")
                    }
                .buttonStyle(.glass(.clear))
                .glassEffect()
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
}

let fm = FirebaseManager()

func getDocs() {
//    fm.printDocs()
    fm.getDocs()
}

func addPost() {
    // info will be hardcoded for first test
    fm.addPost(
        image: "https://firebasestorage.googleapis.com/v0/b/monone-swift.firebasestorage.app/o/muhammed%20ali%20airport.jpg?alt=media&token=0fcdb4f6-7b95-4e37-8eb4-1f1c8b1bd149",
        name: "boo house",
        address: "2385 Valley Vista Rd",
        rating: 5.0,
        description: "wow man",
        coords: (xLoc: 38.216518189838695, yLoc: -85.69859315920505))
}
#Preview {
    ContentView()
}

