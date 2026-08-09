//
//  MapView.swift
//  spots
//
//  Created by Aiden Gage on 1/22/26.
//

import SwiftUI
import MapKit
import Combine
import SwiftData

struct MapView: View {
    @State private var viewModel = ViewModel()
    
    @Environment(\.globalModelContext) private var swiftModelContainer
    @Environment(\.scenePhase) private var scenePhase // this handles what happens when the app is in the background
    
    @Environment(\.currentUser) private var currentUser
    @Environment(\.buttonsViewModel) private var buttonsViewModel
    @Environment(\.tracker) private var tracker
    
    @Environment(\.db) private var dbService
    @Environment(\.user) private var userService
    
//    @Environment(\.modelContext) private var modelContext
    
    @AppStorage(.settingsMapStyleKey) private var settingMapStyle: MapStyleSetting = .standard
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            GeometryReader { proxy in
                Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedPost) {
                    MapCurrentLocation(hasValidLocation: viewModel.hasValidLocation, latitude: viewModel.coordinates.lat, longitude: viewModel.coordinates.lon)
                    
                    PostFilter(profileToggle: buttonsViewModel.profileToggle, showOnlyBookmarked: buttonsViewModel.showOnlyBookmarked, postsToShow: $viewModel.postsToShow)
                }
                .task { // idk if this does anything
                    buttonsViewModel.bind(currentUser: currentUser, dbService: dbService)
                    await currentUser.storeId()
                }
                .allowsHitTesting(viewModel.touchToggle)
                .mapStyle(viewModel.currentMapStyle) // Apply the reactive style
                .overlay(alignment: .bottomTrailing) {
                    MapStyleButton(style: $viewModel.style)
                    .padding()
                }
                .onAppear {
                    viewModel.style = settingMapStyle
                    buttonsViewModel.startPostListenerForMode()
                    if !viewModel.observersSetUp {
                        viewModel.observeCoordinateUpdates()
                        viewModel.observeLocationAccessDenied()
                        viewModel.observersSetUp = true
                    }
                    viewModel.deviceLocationService.requestLocationUpdates()
                    Task {
                        try await userService.loadBookmarks()
                        //testing this out
                        try await userService.loadUserSocials()
                    }
                }
                .onChange(of: buttonsViewModel.profileToggle) { _, _ in buttonsViewModel.startPostListenerForMode() }
                .onChange(of: buttonsViewModel.showOnlyBookmarked) { _, _ in buttonsViewModel.startPostListenerForMode() }
                .onChange(of: settingMapStyle) { _, newStyle in viewModel.style = newStyle }
                .onChange(of: dbService.posts) { _, newPosts in
                    viewModel.postsToShow = if buttonsViewModel.profileToggle && buttonsViewModel.showOnlyBookmarked {
                        newPosts.filter { userService.getBookmarks().contains($0.id) }
                    } else {
                        newPosts
                    }
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    switch newPhase {
                    case .active:
                        print("app active !")
                    case .inactive:
                        print("app inactive")
                    case .background:
                        print("app in background")
                        let backgroundContext = ModelContext(swiftModelContainer)
                        
                        Task {
                            async let itemSync: () = tracker.syncItems(context: backgroundContext)
                            async let snapshotSync: () = tracker.syncSnapshots(context: backgroundContext)
                            
                            await itemSync
                            await snapshotSync
                        }
                    @unknown default:
                        print("unexpected future lifecycle reached")
                    }
                }
                .onDisappear {
                    // stops post listener
                    dbService.stopPostListener()
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
                .safeAreaInset(edge: .bottom) { // remove this later with custom sheet
                    if !viewModel.touchToggle {
                        Color.clear.frame(height: proxy.size.height * 0.70)
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if currentUser.uid != nil {
                            FeedbackButton()
                            ActivityFilter(viewModel: buttonsViewModel)
                            SettingsButton()
                        }
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    AddButton(path: $viewModel.path, centerLat: $viewModel.coordinates.lat, centerLong: $viewModel.coordinates.lon)
                }
                .overlay(alignment: .topLeading) {
                    VerticalDropdownToolbar(path: $viewModel.path)
                }
                .overlay(alignment: .topTrailing) {
                    TrackerWidget(showPost: $viewModel.isViewingPost)
                        .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
