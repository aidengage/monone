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
    @StateObject private var viewModel = ViewModel()
    @StateObject var buttonsViewModel = Buttons.ButtonsViewModel()
    
    var body: some View {
        //the viewModel navigates the path for each screen.
        NavigationStack(path: $viewModel.path) {
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .bottomLeading) {
                    ZStack {
                        
                        Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedPost) {
                            
                            // for curr location, display a marker (only when we have valid coordinates)
                            if viewModel.hasValidLocation {
                                Annotation("Current Location", coordinate: CLLocationCoordinate2D(latitude: viewModel.coordinates.lat, longitude: viewModel.coordinates.lon)) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                            }
                            
                            // Explore = all posts. Profile = my posts, or (when bookmark tapped) my bookmarked posts from all users.
                            //lowkey neat because you're setting a variable based on an if condition
                            let postsToShow: [Post] = if buttonsViewModel.profileToggle && buttonsViewModel.showOnlyBookmarked {
                                Firebase.shared.posts.filter { Firebase.shared.bookmarkedPostIds.contains($0.id) }
                            } else {
                                Firebase.shared.posts
                            }
                            
                            ForEach(postsToShow.filter { $0.latitude != 0.0 && $0.longitude != 0.0 }) { post in
                                Marker(post.name, systemImage: ActivityType.from(post.selectedActivity).icon, coordinate: CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude))
                                    .tag(post)
                                    .tint(ActivityType.from(post.selectedActivity).color) // throws the warning for some reason for unknown even when it is not unknown
                                
                            }
                        }
                        .mapStyle(viewModel.currentMapStyle) // Apply the reactive style
                        .overlay(alignment: .bottomTrailing) {
                            Button(action: {
                                // Action to cycle through the map styles
                                switch viewModel.selectedMapStyleType {
                                case .standard:
                                    viewModel.selectedMapStyleType = .hybrid
//                                case .imagery:
//                                    viewModel.selectedMapStyleType = .standard
                                case .hybrid:
                                    viewModel.selectedMapStyleType = .standard
                                }
                            }) {
                                Image(systemName: "map")
                                    .padding(5)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .tint(.black)
                            }
                            .padding()
                        }
                        // loads posts when the map appears
                        .onAppear {
                            buttonsViewModel.startPostListenerForMode()
                            if !viewModel.observersSetUp {
                                viewModel.observeCoordinateUpdates()
                                viewModel.observeLocationAccessDenied()
                                viewModel.observersSetUp = true
                            }
                            viewModel.deviceLocationService.requestLocationUpdates()
                            Firebase.shared.loadBookmarks()
                        }
                        .onChange(of: buttonsViewModel.profileToggle) { _, _ in buttonsViewModel.startPostListenerForMode() }
                        .onChange(of: buttonsViewModel.showOnlyBookmarked) { _, _ in buttonsViewModel.startPostListenerForMode() }
                        .onDisappear {
                            // stops post listener
                            Firebase.shared.stopPostListener()
                            print("map disappeared, stopping post listener")
                        }
                        // when map camera changes, update center coords with new center
                        .onMapCameraChange { mapCameraUpdateContext in
                            viewModel.update(centerLat: mapCameraUpdateContext.camera.centerCoordinate.latitude)
                            viewModel.update(centerLong: mapCameraUpdateContext.camera.centerCoordinate.longitude)
                            print("\(viewModel.centerLat): \(viewModel.centerLong)")
                            //later used by Add Button to create a post at the center of the screen
                        }
                        
                        // visual indicator of the center of the screen
                        Image(systemName: "mappin")
                            .offset(y: -15)
                            .font(.system(size: 33))
                    }
                    Buttons.AddButton(path: $viewModel.path, centerLat: $viewModel.centerLat, centerLong: $viewModel.centerLong)
                        .padding(.bottom, 5)
                }
                VerticalDropdownToolbar(viewModel: buttonsViewModel)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if Firebase.shared.getCurrentUser() != nil {
                    Buttons.FeedbackButton(path: $viewModel.path)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Buttons.SmokeFilter(viewModel: buttonsViewModel)
            }
            ToolbarItem(placement: .bottomBar) {
                Buttons.DateFilter(viewModel: buttonsViewModel)
            }
            ToolbarItem(placement: .bottomBar) {
                Buttons.PhotographyFilter(viewModel: buttonsViewModel)
            }
            ToolbarItem(placement: .bottomBar) {
                Buttons.TrainstationFilter(viewModel: buttonsViewModel)
            }
            ToolbarItem(placement: .bottomBar) {
                Buttons.UnknownFilter(viewModel: buttonsViewModel)
            }
        }
   
        }
        .sheet(item: $viewModel.selectedPost, onDismiss: {
            buttonsViewModel.startPostListenerForMode()
            
            withAnimation(.easeInOut(duration: 0.2)) {
                buttonsViewModel.showAll.toggle()
            }
        }) { post in
            PostDetailView(post: post)
                .presentationDetents([.fraction(0.75)])
                .presentationBackground(.clear)
//                .presentationBackgroundInteraction(.enabled)
                .task {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        viewModel.cameraZoomOnPost(post: post)
                        buttonsViewModel.showAll.toggle()
                    }
                }
        }
    }
}

enum MapStyleType {
    case standard, /*imagery ,*/ hybrid
}

#Preview {
    MapView()
}
