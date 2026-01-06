//
//  AddPostView.swift
//  spots
//
//  Created by Aiden Gage on 1/4/26.
//

import SwiftUI
import PhotosUI
import MapKit
import CoreLocation
import Foundation

struct PhotosSelector: View {
    @State var selectedItems: [PhotosPickerItem] = []


    var body: some View {
        PhotosPicker(selection: $selectedItems, matching: .images) {
            Text("Select Multiple Photos")
        }
    }
    
    func howManyPhotos() {
        print("Selected \(selectedItems.count) items.")
    }
}

struct AddPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State var centerLat: Double
    @State var centerLong: Double
    @State var title: String = ""
    @State var description: String = ""
    @State var address: String = ""
    @State var imageURL: String = ""
    @State var rating: Double = 0.0
    
    init(centerLat: Double, centerLong: Double) {
        _centerLat = State(initialValue: centerLat)
        _centerLong = State(initialValue: centerLong)
    }
    
    var body: some View {
        VStack {

            Form {
                Section(header: Text("Add a new post")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Address", text: $address)
                    
                }
                Section(header: Text("Rating")) {
                    HStack {
                        TextField("Rating", value: $rating, format: .number)
                            .frame(width: 35)
                            .keyboardType(.decimalPad)
                        Slider(value: $rating, in: 0...5, step: 0.05)
                    }
                    
                }
                Section(header: Text("Image Upload")) {
//                    TextField("image upload wip", text: $imageURL)
                    PhotosSelector()
//                    TextField("image upload wip", text: .constant(""))
                }
                Section(header: Text("Coordinates")) {
                    HStack {
                        
                        TextField("Latitude", value: $centerLat, format: .number)
                            .keyboardType(.decimalPad)
                        TextField("Longitude", value: $centerLong, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            let fm = FirebaseManager()
            Button(action: {
                if title.isEmpty || address.isEmpty || description.isEmpty || /*rating == 0.0 ||*/ centerLat == 0.0 || centerLong == 0.0 {
                    print("add every value to post")
                } else {
                    // add post
                    fm.addPost(image: imageURL, name: title, address: address, rating: rating, description: description, coords: (centerLat, centerLong))
                    
                    dismiss()
                }
            }) {
                Label("Post!", systemImage: "plus")
            }
//            .buttonStyle(.glass(.clear))
            .buttonStyle(.glassProminent)
//            .glassEffect()
        }
        .navigationTitle("Add Post")
        
        // task to use coords and receive its address if there is one
        .task {
            do {
                address = try await ReverseGeocoding().nearestAddress(location: CLLocation(latitude: centerLat, longitude: centerLong))?.address ?? "nil"
            } catch {
                address = "unknown"
                print("reverse geocoding failed: \(error)")
            }
        }
    }
}

// all for reverse geocoding to get the nearest address to the coordinates
struct Place {
    let lat: Double
    let long: Double
    let address: String
    
    init(from mapItem: MKMapItem) {
        self.lat = mapItem.location.coordinate.latitude
        self.long = mapItem.location.coordinate.longitude
        self.address = mapItem.address?.fullAddress ?? "Unknown Address"
    }
}

struct ReverseGeocoding {
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
