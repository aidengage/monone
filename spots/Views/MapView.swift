//
//  MapView.swift
//  spots
//
//  Created by Aiden Gage on 1/22/26.
//

import SwiftUI
import MapKit
import Combine

struct MainMapView: View {
    @State private var hasValidLocation = false
    @State private var hasCenteredOnUser = false
    @State private var observersSetUp = false
    
    @State private var posts: [PostMan] = []
    @State var selectedPost: PostMan? = nil
    
    @State var coordinates: (lat: Double, lon: Double) = (0,0)
    @State var centerLat: Double
    @State var centerLong: Double
    
    @StateObject var deviceLocationService = DeviceLocationService.shared
    @State var tokens: Set<AnyCancellable> = []
    
    @Binding var path: NavigationPath
    
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
                        
                        //for curr location, display a marker (only when we have valid coordinates)
                        if hasValidLocation {
                            Annotation("Current Location", coordinate: CLLocationCoordinate2D(latitude: coordinates.lat, longitude: coordinates.lon)) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                        }
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
                        Firebase.shared.getAllPosts { loadedPosts in
                            DispatchQueue.main.async {
                                self.posts = loadedPosts
                            }
                        }
                        // Set up location observers only once
                        if !observersSetUp {
                            observeCoordinateUpdates()
                            observeLocationAccessDenied()
                            observersSetUp = true
                        }
                        // Request location updates every time view appears (in case app was backgrounded)
                        deviceLocationService.requestLocationUpdates()
                    }
                    // when map camera changes, update center coords with new center
                    .onMapCameraChange { mapCameraUpdateContext in
                        centerLat = mapCameraUpdateContext.camera.centerCoordinate.latitude
                        centerLong = mapCameraUpdateContext.camera.centerCoordinate.longitude
                        print("\(centerLat): \(centerLong)")
                    }
//                    .ignoresSafeArea()
                    
                    // change map safe areas when postview is true to recenter map upward above sheet
                    
                    
                    // visual indicator of the center of the screen
                    Image(systemName: "mappin")
                        .offset(y: -15)
                        .font(.system(size: 33))
                }
            AddButton(path: $path, centerLat: centerLat, centerLong: centerLong)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // creates a toolbar to logout of account
            ToolbarItem(placement: .navigationBarTrailing) {
                let currentUser = Firebase.shared.getCurrentUser()
                if currentUser != nil {
                    Button(action: {
                        Firebase.shared.logout()
                    }) {
                        Label("Logout", systemImage: "arrow.right.square")
                    }
                } else {
                    //change button visibility to false
                }
            }
        }
            
            
        }
        .sheet(item: $selectedPost, onDismiss: {
//            .sheet(item: , onDismiss: {
//            postView = false
//            print("post view: \(postView)")
            withAnimation(.easeInOut(duration: 0.6)) {
                
            }
//                loadPosts()
        }) { post in
            PostDetailView(post: post)
                .presentationDetents([.fraction(0.75)])
            
                .task {
                    withAnimation(.easeInOut(duration: 0.7)) {
//                        postView = true
//                        print("post view: \(postView)")
                        cameraZoomOnPost(post: selectedPost!)
                    }
                }
        }
//        AddButton(path: $path, centerLat: centerLat, centerLong: centerLong)
//        .ignoresSafeArea()
        
        
    }
    
    func cameraZoomOnPost(post: PostMan) {
        let targetLocation = CLLocationCoordinate2D(latitude: post.coords.0, longitude: post.coords.1)
        let zoomLevel = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: targetLocation, span: zoomLevel)
//        cameraPosition = .region(region)
        
        // hardcoded offset camera zoom that barely works
        let offsetCenter = CLLocationCoordinate2D(latitude: post.coords.0 - 0.006, longitude: post.coords.1)
        let offsetRegion = MKCoordinateRegion(center: offsetCenter, span: zoomLevel)
        cameraPosition = .region(offsetRegion)
//        return postView
    }

    //using publisher provided by deviceLocationService
    func observeCoordinateUpdates(){
        deviceLocationService.coordinatesPublisher
            .receive(on: DispatchQueue.main)
            .sink{ completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            } receiveValue: { coordinates in
                // Update coordinates and mark as valid
                self.coordinates = (coordinates.latitude, coordinates.longitude)
                self.hasValidLocation = true
                
                // Center map on user's location the first time we get it
                if !hasCenteredOnUser {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: coordinates,
                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        )
                    )
                    hasCenteredOnUser = true
                }
                
            }
            .store(in: &tokens)
    }
    
    func observeLocationAccessDenied(){
        deviceLocationService.deniedLocationAccessPublisher
            .receive(on: DispatchQueue.main)
            .sink{
                print("location denied")
            }
            .store(in: &tokens)
    }
}

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    print("locations = \(locValue.latitude) \(locValue.longitude)")
}
