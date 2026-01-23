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
import Combine

struct ContentView: View {
    //these are implementations of DeviceLocationManager
//    @StateObject var deviceLocationService = DeviceLocationService.shared
//    @State var tokens: Set<AnyCancellable> = []
//    @State var coordinates: (lat: Double, lon: Double) = (0,0)
//    @State private var hasValidLocation = false
//    @State private var hasCenteredOnUser = false
//    @State private var observersSetUp = false
    
    
    // coords for center of the screen, sent to addpost view to autofill
    @State var centerLat: Double
    @State var centerLong: Double
//    @State private var posts: [PostMan] = []
    //tracks which post is selected
//    @State private var selectedPost: PostMan? = nil
    
    // boolean variables set to show login or add post page for conditional
    // probably dont need this many
//    @State private var showAddPost = false
//    @State private var showLogin = false
    
//    @State private var postView = false
//    @State private var bottomInset: CGFloat = 0
    
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
            ZStack(alignment: .bottomLeading) {
                ZStack {
                    MainMapView(centerLat: 0, centerLong: 0, path: $path)
                }
            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                // creates a toolbar to logout of account
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    let currentUser = Auth.auth().currentUser
//                    if currentUser != nil {
//                        Button(action: {
//                            Firebase.shared.logout()
//                        }) {
//                            Label("Logout", systemImage: "arrow.right.square")
//                        }
//                    } else {
//                        //change button visibility to false
//                        
//                        
//                            
//                    }
//                }
//            }
            //once state of selectedPost changes, PostDetailView with post is launched. 
//            .sheet(item: $selectedPost, onDismiss: {
////            .sheet(item: , onDismiss: {
//                postView = false
//                print("post view: \(postView)")
//                withAnimation(.easeInOut(duration: 0.6)) {
//                    
//                }
////                loadPosts()
//            }) { post in
//                PostDetailView(post: post)
//                    .presentationDetents([.fraction(0.75)])
//                
//                    .task {
//                        withAnimation(.easeInOut(duration: 0.7)) {
//                            postView = true
//                            print("post view: \(postView)")
//                            cameraZoomOnPost(post: selectedPost!)
//                        }
//                    }
//            }
//        }
    }
    
//    func cameraZoomOnPost(post: PostMan) {
//        let targetLocation = CLLocationCoordinate2D(latitude: post.coords.0, longitude: post.coords.1)
//        let zoomLevel = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        let region = MKCoordinateRegion(center: targetLocation, span: zoomLevel)
////        cameraPosition = .region(region)
//        
//        // hardcoded offset camera zoom that barely works
//        let offsetCenter = CLLocationCoordinate2D(latitude: post.coords.0 - 0.006, longitude: post.coords.1)
//        let offsetRegion = MKCoordinateRegion(center: offsetCenter, span: zoomLevel)
//        cameraPosition = .region(offsetRegion)
////        return postView
//    }
//
//    //using publisher provided by deviceLocationService
//    func observeCoordinateUpdates(){
//        deviceLocationService.coordinatesPublisher
//            .receive(on: DispatchQueue.main)
//            .sink{ completion in
//                if case .failure(let error) = completion {
//                    print(error)
//                }
//            } receiveValue: { coordinates in
//                // Update coordinates and mark as valid
//                self.coordinates = (coordinates.latitude, coordinates.longitude)
//                self.hasValidLocation = true
//                
//                // Center map on user's location the first time we get it
//                if !hasCenteredOnUser {
//                    cameraPosition = .region(
//                        MKCoordinateRegion(
//                            center: coordinates,
//                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//                        )
//                    )
//                    hasCenteredOnUser = true
//                }
//                
//            }
//            .store(in: &tokens)
//    }
//    
//    func observeLocationAccessDenied(){
//        deviceLocationService.deniedLocationAccessPublisher
//            .receive(on: DispatchQueue.main)
//            .sink{
//                print("location denied")
//            }
//            .store(in: &tokens)
//    }
    
    // uses firebasemanager getposts with the completion below
//    func loadPosts() {
//        FirebaseManager.shared.getPosts(completion: completion)
//    }
    
    //this completion handler is triggered once the posts are loaded, and it updates the posts state variable because there is a state change in the posts variable (going from empty to having data)
//    func handleLoadedPosts(loadedPosts: [PostMan]) {
//        print("\(loadedPosts.count) posts from Firebase")
//        for (index, post) in loadedPosts.enumerated() {
//            print("   Post \(index + 1): \(post.title) - Coords: (\(post.coords.0), \(post.coords.1)), Rating: \(post.rating)")
//            print(post)
//        }
//        posts = loadedPosts
//        print("Updated posts state variable. Map will now render markers.")
//    }
}

//func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//    guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//    print("locations = \(locValue.latitude) \(locValue.longitude)")
//}


#Preview {
    ContentView(centerLat: 0.0, centerLong: 0.0)
}

