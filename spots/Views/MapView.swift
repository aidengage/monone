//
//  MapView.swift
//  spots
//
//  Created by Aiden Gage on 1/22/26.
//

import SwiftUI
import MapKit
import Combine

struct MapView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ZStack(alignment: .bottomLeading) {
                ZStack {
                
                    
                    Map(position: $viewModel.cameraPosition) {
                        
                        //for curr location, display a marker (only when we have valid coordinates)
                        if viewModel.hasValidLocation {
                            Annotation("Current Location", coordinate: CLLocationCoordinate2D(latitude: viewModel.coordinates.lat, longitude: viewModel.coordinates.lon)) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                        }
                        // looping through posts array and displaying them all on map with a clickable marker
                        ForEach(viewModel.posts.filter { $0.coords.0 != 0.0 && $0.coords.1 != 0.0 }) { post in
                            Annotation(post.title, coordinate: CLLocationCoordinate2D(latitude: post.coords.0, longitude: post.coords.1)) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        // once user taps, state of selectedPost changes
                                        viewModel.selectedPost = post
                                    }
                            }
                        }
                    }
                    // loads posts when the map appears
                    .onAppear {
                        Firebase.shared.getAllPosts { loadedPosts in
                            DispatchQueue.main.async {
                                viewModel.posts = loadedPosts
                            }
                        }
                        // Set up location observers only once
                        if !viewModel.observersSetUp {
                            viewModel.observeCoordinateUpdates()
                            viewModel.observeLocationAccessDenied()
                            viewModel.observersSetUp = true
                        }
                        // Request location updates every time view appears (in case app was backgrounded)
                        viewModel.deviceLocationService.requestLocationUpdates()
                    }
                    // when map camera changes, update center coords with new center
                    .onMapCameraChange { mapCameraUpdateContext in
                        viewModel.update(centerLat: mapCameraUpdateContext.camera.centerCoordinate.latitude)
                        viewModel.update(centerLong: mapCameraUpdateContext.camera.centerCoordinate.longitude)
//                        viewModel.centerLat = mapCameraUpdateContext.camera.centerCoordinate.latitude
//                        viewModel.centerLong = mapCameraUpdateContext.camera.centerCoordinate.longitude
                        print("\(viewModel.centerLat): \(viewModel.centerLong)")
                    }
                    
                    // visual indicator of the center of the screen
                    Image(systemName: "mappin")
                        .offset(y: -15)
                        .font(.system(size: 33))
                }
                AddButton(path: $viewModel.path, centerLat: $viewModel.centerLat, centerLong: $viewModel.centerLong)
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
        .sheet(item: $viewModel.selectedPost, onDismiss: {
            // camera zoom back out needs to be implemented
        }) { post in
            PostDetailView(post: post)
                .presentationDetents([.fraction(0.75)])
                .task {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        viewModel.cameraZoomOnPost(post: viewModel.selectedPost!)
                    }
                }
        }
    }
}
