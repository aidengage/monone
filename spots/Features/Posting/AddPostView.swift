//
//  AddPostView.swift
//  spots
//
//  Created by Aiden Gage on 1/4/26.
//

import SwiftUI
import MapKit
import CoreLocation
import Foundation

import PhotosUI
import FirebaseStorage

struct AddPostView: View {
    @Environment(\.post) private var postService
    @State private var viewModel = ViewModel()
    
    @State private var showCamera: Bool = false
//    @StateObject private var cameraManager = CameraManager()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.currentUser) private var currentUser
    
    @FocusState private var focusedField: KeyboardField?
    
    
    
    
//    lazy var coordinateStream: AsyncStream<CLLocationCoordinate2D> = {
//        AsyncStream { continuation in
//            viewModel.coordinateContinuation = continuation
//        }
//    }()

    init(centerLat: Double, centerLong: Double) {
        // state variables received from contentview
        // center x and y for post location
        viewModel.centerLat = centerLat
        viewModel.centerLong = centerLong
        
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // title, description, and address for where pin is
                //*need to check if address autofills.
                Section(header: Text("Add a new post")) {
                    TextField("Title", text: $viewModel.title)
                        .focused($focusedField, equals: .title)
                        .textContentType(.name)
                        .submitLabel(.next)
                    TextField("Address", text: $viewModel.address)
                        .focused($focusedField, equals: .address)
                        .textContentType(.fullStreetAddress)
                        .submitLabel(.next)
                }
                
                Section(header: Text("Refine your location!")) {
                    RefineLocationPickerView(lat: $viewModel.centerLat, lon: $viewModel.centerLong)
                }
                
                Section(header: Text("Write your comment!")) {
                    TextField("what did you think??", text: $viewModel.comment, axis: .vertical)
                        .focused($focusedField, equals: .comment)
                        .submitLabel(.join)
                }
                
                Section(header: Text("Activity Type")) {
                    Picker("Activity", selection: $viewModel.selectedActivity) {
                        ForEach(ActivityType.allCases) { type in
                            Text(type.displayActivity).tag(type)
                        }
                    }
                }
                
                // rating needs to link back to user posting it
                Section(header: Text("Rating")) {
                    StarRatingViewDynamic(rating: $viewModel.rating, numStars: 5)
                }
                // custom photo picker logic in AddPostView and FirebaseManager
                //            Section(header: Text("Image Upload")) {
                //                PhotoSelector(data: $viewModel.imageData, imageUUIDs: $viewModel.imageUUIDs, images: $viewModel.images, maxPhotos: 6)
                Button(action: {
                    showCamera.toggle()
                    print("show camera bool: \(showCamera)")
                }) {
                    Label("open camera", systemImage: "camera.fill")
                }
                .buttonStyle(.glassProminent)
                .sheet(isPresented: $showCamera) {
                    MijickCameraView(selectedImages: $viewModel.images)
                }
                //                    .fullScreenCover(isPresented: $showCamera) {
                //                .sheet(isPresented: $showCamera) {
                //                    CameraView(cameraManager: cameraManager, photoLimit: 6, enablePhoto: true, enableVideo: false, selectedImages: $viewModel.images)
                //                }
                //            }
                
                // autofilled coordinates based on where the pin is
                Section(header: Text("Coordinates")) {
                    HStack {
                        TextField("Latitude", value: $viewModel.centerLat, format: .number)
                            .keyboardType(.decimalPad)
                        TextField("Longitude", value: $viewModel.centerLong, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Button(action: {
                    if viewModel.title.isEmpty || viewModel.address.isEmpty || /*viewModel.comment.isEmpty ||*/ /*rating == 0.0 ||*/ viewModel.centerLat == 0.0 || viewModel.centerLong == 0.0 || viewModel.imageData == [] {
                        print("add every value to post")
                    } else {
                        // add post
                        // uses the global shared firebasemanager object in the firebasemanager class
                        Task {
                            try await postService.addPost(images: viewModel.images, imagesUUIDs: viewModel.imageUUIDs, name: viewModel.title, address: viewModel.address, rating: viewModel.rating, ratingCount: viewModel.ratingCount, comment: viewModel.comment, coords: (lat: viewModel.centerLat, long: viewModel.centerLong), selectedActivity: viewModel.selectedActivity.displayActivity)
                        }
                        
                        dismiss()
                    }
                }) {
                    Text("Post!")
                }
                .buttonStyle(.glassProminent)
                
                
                
            }
            .onAppear {
                addTapGestureToDismissKeyboard()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add Post")
            // task to use coords and receive its address if there is one
            // also sets the name if available
//            .sheet(isPresented: $showCamera) {
//                MijickCameraView(selectedImages: $viewModel.images)
//            }
            .task {
                var lastLat: Double? = nil
                var lastLon: Double? = nil
                let geocoder = ReverseGeocoding()
                
                while !Task.isCancelled {
                    if viewModel.centerLat != lastLat || viewModel.centerLong != lastLon {
                        lastLat = viewModel.centerLat
                        lastLon = viewModel.centerLong
                        
                        do {
                            
                            viewModel.address = try await geocoder.nearestAddress(location: CLLocation(latitude: viewModel.centerLat, longitude: viewModel.centerLong))?.address ?? "nil"
                            
                        } catch {
                            viewModel.address = "unknown"
                            print("reverse geocoding failed: \(error)")
                        }
                    }
                    try? await Task.sleep(for: .seconds(0.5))
                }
            }
        }
        
//        .task {
//            var debounceTask: Task<Void, Never>?
//            
//            for await coordinate in viewModel.coordinateStream {
//                // Cancel the previous pending geocode
//                debounceTask?.cancel()
//                
//                debounceTask = Task {
//                    // Wait for user to stop moving before geocoding
//                    try? await Task.sleep(for: .milliseconds(500))
//                    guard !Task.isCancelled else { return }
//                    
//                    do {
//                        viewModel.address = try await ReverseGeocoding().nearestAddress(location: CLLocation(latitude: viewModel.centerLat, longitude: viewModel.centerLong))?.address ?? "nil"
//                    } catch {
//                        viewModel.address = "unknown"
//                        print("reverse geocoding failed: \(error)")
//                    }
//                }
//            }
//        }
    }
}

