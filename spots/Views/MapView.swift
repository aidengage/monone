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
                        ForEach(Firebase.shared.posts.filter { $0.latitude != 0.0 && $0.longitude != 0.0 }) { post in
                            Annotation(post.name, coordinate: CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude)) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        // once user taps, state of selectedPost changes
//                                        viewModel.selectedPost = post
                                        viewModel.listenedToSelectedPost = post
                                    }
                            }
                        }
                    }
                    // loads posts when the map appears
                    .onAppear {
                        // starts post listener
                        Firebase.shared.startPostListener()
                        
                        // Set up location observers only once
                        if !viewModel.observersSetUp {
                            viewModel.observeCoordinateUpdates()
                            viewModel.observeLocationAccessDenied()
                            viewModel.observersSetUp = true
                        }
                        // Request location updates every time view appears (in case app was backgrounded)
                        viewModel.deviceLocationService.requestLocationUpdates()
                    }
                    .onDisappear {
                        // stops post listener
                        Firebase.shared.stopPostListener()
                    }
                    // when map camera changes, update center coords with new center
                    .onMapCameraChange { mapCameraUpdateContext in
                        viewModel.update(centerLat: mapCameraUpdateContext.camera.centerCoordinate.latitude)
                        viewModel.update(centerLong: mapCameraUpdateContext.camera.centerCoordinate.longitude)
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
        .sheet(item: $viewModel.listenedToSelectedPost, onDismiss: {
            // camera zoom back out needs to be implemented
        }) { post in
            PostDetailView(post: post)
                .presentationDetents([.fraction(0.75)])
                .task {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        viewModel.cameraZoomOnPost(post: viewModel.listenedToSelectedPost!)
                    }
                }
        }
    }
}
