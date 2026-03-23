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
        //the viewModel navigates the path for each screen.
        NavigationStack(path: $viewModel.path) {
            ZStack(alignment: .bottomLeading) {
                ZStack {
                
                    
                    Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedPost) {
                        
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
                        // Explore = all posts. Profile = my posts, or (when bookmark tapped) my bookmarked posts from all users.
                        //lowkey neat because you're setting a variable based on an if condition 
                        let postsToShow: [Post] = if viewModel.profileToggle && viewModel.showOnlyBookmarked {
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
                    // loads posts when the map appears
                    .onAppear {
                        startPostListenerForMode()
                        if !viewModel.observersSetUp {
                            viewModel.observeCoordinateUpdates()
                            viewModel.observeLocationAccessDenied()
                            viewModel.observersSetUp = true
                        }
                        viewModel.deviceLocationService.requestLocationUpdates()
                        Firebase.shared.loadBookmarks()
                    }
                    .onChange(of: viewModel.profileToggle) { _, _ in startPostListenerForMode() }
                    .onChange(of: viewModel.showOnlyBookmarked) { _, _ in startPostListenerForMode() }
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
                AddButton(path: $viewModel.path, centerLat: $viewModel.centerLat, centerLong: $viewModel.centerLong)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // creates a toolbar to logout of account
            ToolbarItem(placement: .navigationBarTrailing) {
                if Firebase.shared.getCurrentUser() != nil {
                    Button(action: {
                        Firebase.shared.logout()
                    }) {
                        Label("Logout", systemImage: "arrow.right.square")
                    }
                    .buttonStyle(.glassProminent)
                } else {
                    //change button visibility to false
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if Firebase.shared.getCurrentUser() != nil {
                    ProfileButton(profileToggle: $viewModel.profileToggle)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if /*Firebase.shared.getCurrentUser() != nil,*/ viewModel.profileToggle {
                    Button(action: {
                        viewModel.showOnlyBookmarked.toggle()
                    }) {
                        Label(
                            viewModel.showOnlyBookmarked ? "Show all" : "Bookmarks",
                            systemImage: viewModel.showOnlyBookmarked ? "bookmark.fill" : "bookmark"
                        )
                    }
                    .tint(viewModel.showOnlyBookmarked ? .blue : .primary)
                    .buttonStyle(.glassProminent)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if Firebase.shared.getCurrentUser() != nil {
                    FeedbackButton(path: $viewModel.path)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    viewModel.showSmoke.toggle()
                    viewModel.showDate = false
                    viewModel.showPhoto = false
                    viewModel.showTrain = false
                    viewModel.showUnknown = false
                    
                    if viewModel.showSmoke {
                        print(viewModel.showSmoke)
                        Firebase.shared.startPostActivityListener(activity: .smoke)
                    } else {
                        startPostListenerForMode()
                    }
                }) {
                    Label(viewModel.showSmoke ? "Hide smoke" : "Show smoke",
                          systemImage: ActivityType.smoke.icon)
                }
                .tint(ActivityType.smoke.color)
                .buttonStyle(.glassProminent)
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    viewModel.showSmoke = false
                    viewModel.showDate.toggle()
                    viewModel.showPhoto = false
                    viewModel.showTrain = false
                    viewModel.showUnknown = false
                    
                    if viewModel.showDate {
                        Firebase.shared.startPostActivityListener(activity: .date)
                    } else {
                        startPostListenerForMode()
                    }
                }) {
                    Label(viewModel.showDate ? "hide date" : "show date",
                          systemImage: ActivityType.date.icon)
                }
                .tint(ActivityType.date.color)
                .buttonStyle(.glassProminent)
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    viewModel.showSmoke = false
                    viewModel.showDate = false
                    viewModel.showPhoto.toggle()
                    viewModel.showTrain = false
                    viewModel.showUnknown = false
                    
                    if viewModel.showPhoto {
                        Firebase.shared.startPostActivityListener(activity: .photography)
                    } else {
                        startPostListenerForMode()
                    }
                }) {
                    Label(viewModel.showPhoto ? "hide photo" : "show photo",
                          systemImage: ActivityType.photography.icon)
                }
                .tint(ActivityType.photography.color)
                .buttonStyle(.glassProminent)
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    viewModel.showSmoke = false
                    viewModel.showDate = false
                    viewModel.showPhoto = false
                    viewModel.showTrain.toggle()
                    viewModel.showUnknown = false
                    
                    if viewModel.showTrain {
                        Firebase.shared.startPostActivityListener(activity: .trainStation)
                    } else {
                        startPostListenerForMode()
                    }
                }) {
                    Label(viewModel.showTrain ? "hide train" : "show train",
                          systemImage: ActivityType.trainStation.icon)
                }
                .tint(ActivityType.trainStation.color)
                .buttonStyle(.glassProminent)
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    viewModel.showSmoke = false
                    viewModel.showDate = false
                    viewModel.showPhoto = false
                    viewModel.showTrain = false
                    viewModel.showUnknown.toggle()
                    
                    if viewModel.showUnknown {
                        Firebase.shared.startPostActivityListener(activity: .unknown)
                    } else {
                        startPostListenerForMode()
                    }
                }) {
                    Label(viewModel.showUnknown ? "hide unknown" : "show unknown",
                          systemImage: ActivityType.unknown.icon)
                }
                .tint(ActivityType.unknown.color)
                .buttonStyle(.glassProminent)
            }
        }
   
        }
        .sheet(item: $viewModel.selectedPost, onDismiss: {
            startPostListenerForMode()
        }) { post in
            PostDetailView(post: post /*viewModel.selectedPost!*/ /*, ratings: Firebase.shared.ratings*/)
                .presentationDetents([.fraction(0.75)])
                .task {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        viewModel.cameraZoomOnPost(post: post /*viewModel.selectedPost!*/)
                    }
                }
        }
    }
    
    /// Profile off = all posts. Profile on, no bookmark filter = my posts. Profile on, bookmark on = all posts (filter in view to bookmarked).
    private func startPostListenerForMode() {
        if !viewModel.profileToggle {
            Firebase.shared.startPostListener()
        } else if viewModel.showOnlyBookmarked {
            Firebase.shared.startPostListener()
        } else {
            Firebase.shared.startUserPostListener(userId: Firebase.shared.getCurrentUserID())
        }
    }
}
