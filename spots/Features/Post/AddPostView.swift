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
    
    // need to be able to send the uuid of each photo when uploading them and saving them in the post object
    
    @Environment(\.dismiss) private var dismiss
    @State var centerLat: Double
    @State var centerLong: Double
    @State var title: String = ""
    @State var comment: String = ""
    @State var address: String = ""
    @State var imageURL: String = ""
    @State var rating: Decimal = 0.0
    @State var ratingCount: Int = 0
    
    @State var imageData: [Data] = []
    @State var imageUUIDs: [String] = []
    @State var selectedActivty: String = "Smoke"
    let activityType = ["Smoke", "Photography", "Date"]
    
    
    init(centerLat: Double, centerLong: Double) {
        // state variables received from contentview
        // center x and y for post location
        _centerLat = State(initialValue: centerLat)
        _centerLong = State(initialValue: centerLong)
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
                    TextField("Title", text: $title)
                    TextField("Description/Comment", text: $comment)
                    TextField("Address", text: $address)
                    
                    
                }
                Section(header: Text("Activity Type")) {
                    Picker("Activity", selection: $selectedActivty) {
                        ForEach(activityType, id: \.self) {
                            Text($0)
                        }
                    }
                }
                    
                    // rating needs to link back to user posting it
                    Section(header: Text("Rating")) {
                        StarRatingViewDynamic(rating: $rating, numStars: 5)
                    }
                    // custom photo picker logic in AddPostView and FirebaseManager
                    Section(header: Text("Image Upload")) {
                        PhotoSelector(data: $imageData, imageUUIDs: $imageUUIDs)
                    }
                    
                    // autofilled coordinates based on where the pin is
                    Section(header: Text("Coordinates")) {
                        HStack {
                            
                            TextField("Latitude", value: $centerLat, format: .number)
                                .keyboardType(.decimalPad)
                            TextField("Longitude", value: $centerLong, format: .number)
                                .keyboardType(.decimalPad)
                        }
                    }
                
                Button(action: {
                    if title.isEmpty || address.isEmpty || comment.isEmpty || /*rating == 0.0 ||*/ centerLat == 0.0 || centerLong == 0.0 || imageData == [] {
                        print("add every value to post")
                    } else {
                        ratingCount += 1
                        // add post
                        // uses the global shared firebasemanager object in the firebasemanager class
                        Task {
                            await Firebase.shared.addPost(images: imageUUIDs, name: title, address: address, rating: rating, ratingCount: ratingCount, comment: comment, coords: (lat: centerLat, long: centerLong), selectedActivity: selectedActivty)
                        }
                        
                        
                        // need to unwrap optional Data type imageData before passing as param
                        // this can be put into seperate upload() function at bottom but later
                        // try catch is for async func
                        Task {
                            do {
                                // need to make it so if the photos arent uploaded to firebase then the photo uuids shouldnt be added to the post
                                try await Firebase.shared.uploadImage(uuidArray: imageUUIDs, data: imageData)
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
                    address = try await ReverseGeocoding().nearestAddress(location: CLLocation(latitude: centerLat, longitude: centerLong))?.address ?? "nil"
                    title = try await ReverseGeocoding().nearestAddress(location: CLLocation(latitude: centerLat, longitude: centerLong))?.name ?? ""
                } catch {
                    address = "unknown"
                    print("reverse geocoding failed: \(error)")
                }
            }
        }
    }
    
    // all for reverse geocoding to get the nearest address to the coordinates
    // saving place information in place object/struct
    struct Place {
        let lat: Double
        let long: Double
        let name: String?
        let address: String
        
        init(from mapItem: MKMapItem) {
            self.lat = mapItem.location.coordinate.latitude
            self.long = mapItem.location.coordinate.longitude
            self.name = mapItem.name
            // changed fullAddress to shortAddress temporarily to avoid double names
            // need to work on how this shows up, want to show the actual address from the full address and the name specifically
            self.address = mapItem.address?.shortAddress ?? "Unknown Address"
        }
    }
    
    struct ReverseGeocoding {
        // gets address from coordinates
        func nearestAddress(location: CLLocation) async throws -> Place? {
            if let request = MKReverseGeocodingRequest(location: location) {
                let mapItems = try await request.mapItems
                return mapItems.first.map(Place.init)
            }
            return nil
        }
    }
    
    #Preview {
        AddPostView(centerLat: 0.0, centerLong: 0.0)
    }
}
