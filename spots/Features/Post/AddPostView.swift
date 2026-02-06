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
    
    // need to be able to send the uuid of each photo when uploading them and saving them in the post object
    
    @Environment(\.dismiss) private var dismiss
//    @State var centerLat: Double
//    @State var centerLong: Double
//    @State var title: String = ""
//    @State var comment: String = ""
//    @State var address: String = ""
//    @State var imageURL: String = ""
//    @State var rating: Decimal = 0.0
//    @State var ratingCount: Int = 0
//    
//    @State var imageData: [Data] = []
//    @State var imageUUIDs: [String] = []
//    @State var selectedActivty: String = "Smoke"
    let activityType = ["Smoke", "Photography", "Date"]
    
    
    init(centerLat: Double, centerLong: Double) {
        // state variables received from contentview
        // center x and y for post location
        viewModel.centerLat = centerLat
        viewModel.centerLong = centerLong
    }
    
    var body: some View {
        VStack {
            // need to resize the grab edge on the left because its annoying to grab the slider
            // also need to figure out better rating system, maybe star
            
            // big form that takes in all the post data
            // photos need to be implemented
            // rating back to user needs to be implemented
            Form {
                // title, description, and address for where pin is
                Section(header: Text("Add a new post")) {
                    TextField("Title", text: $viewModel.title)
                    TextField("Description/Comment", text: $viewModel.comment)
                    TextField("Address", text: $viewModel.address)
                    
                    
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
                        PhotoSelector(data: $viewModel.imageData, imageUUIDs: $viewModel.imageUUIDs)
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
                        if viewModel.comment != "" {
                            viewModel.ratingCount += 1
                        }
                        
                        // add post
                        // uses the global shared firebasemanager object in the firebasemanager class
                        Task {
                            await Firebase.shared.addPost(images: viewModel.imageUUIDs, name: viewModel.title, address: viewModel.address, rating: viewModel.rating, ratingCount: viewModel.ratingCount, comment: viewModel.comment, coords: (lat: viewModel.centerLat, long: viewModel.centerLong), selectedActivity: viewModel.selectedActivty)
                        }
                        
                        
                        // need to unwrap optional Data type imageData before passing as param
                        // this can be put into seperate upload() function at bottom but later
                        // try catch is for async func
                        Task {
                            do {
                                // need to make it so if the photos arent uploaded to firebase then the photo uuids shouldnt be added to the post
                                try await Firebase.shared.uploadImage(uuidArray: viewModel.imageUUIDs, data: viewModel.imageData)
                            } catch {
                                print("upload failed: \(error)")
                            }
                        }
                        dismiss()
                    }
                }) {
                    Label("Post!", systemImage: "plus")
                }
                .buttonStyle(.glassProminent)
            }
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
}
