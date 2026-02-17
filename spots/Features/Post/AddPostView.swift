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
    
    @State private var viewModel = ViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focusedField: KeyboardField?

    let activityType = ["Smoke", "Photography", "Date"]
    
    
    init(centerLat: Double, centerLong: Double) {
        // state variables received from contentview
        // center x and y for post location
        viewModel.centerLat = centerLat
        viewModel.centerLong = centerLong
    }
    
    var body: some View {
        Form {
            // title, description, and address for where pin is
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
            
            Section(header: Text("Write your comment!")) {
                TextField("what did you think??", text: $viewModel.comment, axis: .vertical)
                    .focused($focusedField, equals: .comment)
                    .submitLabel(.join)
            }
            
            Section(header: Text("Activity Type")) {
                Picker("Activity", selection: $viewModel.selectedActivty) {
                    ForEach(activityType, id: \.self) {
                        Text($0)
                    }
                }
            }
                
            // rating needs to link back to user posting it
            Section(header: Text("Rating")) {
                StarRatingViewDynamic(rating: $viewModel.rating, numStars: 5)
            }
            // custom photo picker logic in AddPostView and FirebaseManager
            Section(header: Text("Image Upload")) {
                PhotoSelector(data: $viewModel.imageData, imageUUIDs: $viewModel.imageUUIDs, images: $viewModel.images)
//                            .contentShape(Rectangle())
            }
            
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
                        await Firebase.shared.addPost(images: viewModel.images, imagesUUIDs: viewModel.imageUUIDs, name: viewModel.title, address: viewModel.address, rating: viewModel.rating, ratingCount: viewModel.ratingCount, comment: viewModel.comment, coords: (lat: viewModel.centerLat, long: viewModel.centerLong), selectedActivity: viewModel.selectedActivty)
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
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Add Post")
        // task to use coords and receive its address if there is one
        // also sets the name if available
        .task {
            do {
                viewModel.address = try await ReverseGeocoding().nearestAddress(location: CLLocation(latitude: viewModel.centerLat, longitude: viewModel.centerLong))?.address ?? "nil"
                viewModel.title = try await ReverseGeocoding().nearestAddress(location: CLLocation(latitude: viewModel.centerLat, longitude: viewModel.centerLong))?.name ?? ""
            } catch {
                viewModel.address = "unknown"
                print("reverse geocoding failed: \(error)")
            }
        }
    }
}
