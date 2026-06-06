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
    
    @AppStorage(.settingsMapStyleKey) private var settingMapStyle: MapStyleSetting = .standard
    
    var body: some View {
        //the viewModel navigates the path for each screen.
        NavigationStack(path: $viewModel.path) {
            GeometryReader { proxy in
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
//                            .animation(.easeInOut(duration: 0.6), value: viewModel.cameraPosition) // made rotation super slow
                            .allowsHitTesting(viewModel.touchToggle)
                            .mapStyle(viewModel.currentMapStyle) // Apply the reactive style
                            .overlay(alignment: .bottomTrailing) {
                                Button(action: {
                                    // Action to cycle through the map styles
                                    switch viewModel.style {
                                    case .standard:
                                        viewModel.style = .hybrid
                                    case .hybrid:
                                        viewModel.style = .standard
                                    case .satellite:
                                        viewModel.style = .standard
                                    case .experimental:
                                        viewModel.style = .standard
                                    }
                                }) {
                                    Image(systemName: viewModel.currentMapIcon)
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
                                viewModel.style = settingMapStyle
                                buttonsViewModel.startPostListenerForMode()
                                if !viewModel.observersSetUp {
                                    viewModel.observeCoordinateUpdates()
                                    viewModel.observeLocationAccessDenied()
                                    viewModel.observersSetUp = true
                                }
                                viewModel.deviceLocationService.requestLocationUpdates()
                                Firebase.shared.loadBookmarks()
                                //testing this out
                                Firebase.shared.loadUserSocials()
                            }
                            .onChange(of: buttonsViewModel.profileToggle) { _, _ in buttonsViewModel.startPostListenerForMode() }
                            .onChange(of: buttonsViewModel.showOnlyBookmarked) { _, _ in buttonsViewModel.startPostListenerForMode() }
                            .onChange(of: settingMapStyle) { _, newStyle in viewModel.style = newStyle }
                            .onDisappear {
                                // stops post listener
                                Firebase.shared.stopPostListener()
                                print("map disappeared, stopping post listener")
                            }
                            // when map camera changes, update center coords with new center
                            .onMapCameraChange { mapCameraUpdateContext in
                                viewModel.update(centerLat: mapCameraUpdateContext.camera.centerCoordinate.latitude)
                                viewModel.update(centerLong: mapCameraUpdateContext.camera.centerCoordinate.longitude)
//                                print("\(viewModel.centerLat): \(viewModel.centerLong)")
                                if !viewModel.isViewingPost {
                                    viewModel.lastKnownCamera = mapCameraUpdateContext.camera
                                }
                                //later used by Add Button to create a post at the center of the screen
                            }
                            .safeAreaInset(edge: .bottom) {
                                if !viewModel.touchToggle {
                                    Color.clear.frame(height: proxy.size.height * 0.70)
                                }
                            }
                        }
                        Buttons.AddButton(path: $viewModel.path, centerLat: $viewModel.coordinates.lat, centerLong: $viewModel.coordinates.lon)
                    }
                    // vertical dropdown toolbar doesnt go into toolbar item very well, tried to put it in top left kinda broke
                    VerticalDropdownToolbar(viewModel: buttonsViewModel, path: $viewModel.path)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if Firebase.shared.getCurrentUser() != nil {
                            Buttons.FeedbackButton()
                            Buttons.ActivityFilter(viewModel: buttonsViewModel)
                            Buttons.SettingsButton()
                        }
                    }
                }
            }
            
        }
        .sheet(item: $viewModel.selectedPost, onDismiss: {
            buttonsViewModel.startPostListenerForMode()
            viewModel.exitPost()
            viewModel.touchToggle.toggle()
            withAnimation(.easeInOut(duration: 0.2)) {
                buttonsViewModel.showAll.toggle()
            }
        }) { post in
            PostDetailView(post: post)
                .presentationDetents([.fraction(0.75)])
//                .presentationBackground(.clear)
//                .presentationBackgroundInteraction(.enabled)
                .task {
                    viewModel.touchToggle.toggle()
                    withAnimation(.easeInOut(duration: 0.7)) {
                        viewModel.cameraZoomOnPost(post: post)
                        buttonsViewModel.showAll.toggle()
                    }
                }
        }
    }
}

#Preview {
    MapView()
}
