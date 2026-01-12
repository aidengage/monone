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

// basic photo selector storing images in selectedItems
//struct PhotoSelector: View {
//    @State var selectedItems: [PhotosPickerItem] = []
//
//
//    var body: some View {
//        PhotosPicker(selection: $selectedItems, matching: .images) {
//            Text("Select Multiple Photos")
//        }
//    }
//    
//    func howManyPhotos() {
//        print("Selected \(selectedItems.count) items.")
//    }
//}

struct AddPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State var centerLat: Double
    @State var centerLong: Double
    @State var title: String = ""
    @State var description: String = ""
    @State var address: String = ""
    @State var imageURL: String = ""
    @State var rating: Double = 0.0
    
    @State var imageData: Data?
//    var ps: PhotoSelector
    
    // photo picker
//    @State var data: Data?
//    @State var selectedItem: [PhotosPickerItem] = []
    
    init(centerLat: Double, centerLong: Double) {
        // state variables received from contentview
        // center x and y for post location
        _centerLat = State(initialValue: centerLat)
        _centerLong = State(initialValue: centerLong)
//        ps = PhotoSelector()
    }
    
    var body: some View {
        VStack {

            // big form that takes in all the post data
            // photos need to be implemented
            // rating back to user needs to be implemented
            Form {
                Section(header: Text("Add a new post")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Address", text: $address)
                    
                }
                
                // rating needs to link back to user posting it
                Section(header: Text("Rating")) {
                    HStack {
                        TextField("Rating", value: $rating, format: .number)
                            .frame(width: 35)
                            .keyboardType(.decimalPad)
                        Slider(value: $rating, in: 0...5, step: 0.05)
                    }
                    
                }
                Section(header: Text("Image Upload")) {
                    PhotoSelector(data: $imageData)
                    //                    PhotoSelector()
//                    PhotosPicker(selection: $selectedItem, maxSelectionCount: 1, matching: .images, preferredItemEncoding: .automatic) {
//                        if let data = data, let image = UIImage(data: data) {
//                            Image(uiImage: image)
//                                .resizable()
//                                .scaledToFit()
//                                .frame( maxHeight: 300)
//                        } else {
//                            Label("Select a picture", systemImage: "photo.on.rectangle.angled")
//                        }
//                    }.onChange (of: selectedItem) {_, newValue in
//                        guard let item = selectedItem.first else {
//                            return
//                        }
//                        item.loadTransferable(type: Data.self) { result in
//                            switch result {
//                            case .success(let data):
//                                if let data = data {
//                                    self.data = data
//                                    
//                                }
//                            case .failure(let failure):
//                                print("Error: \(failure.localizedDescription)")
//                            }
//                        }
//                        
//                    }
                    Button("Upload Image") {
//                        print("attempting upload...")
//                        if let data = data {
//                            let storageRef = Storage.storage().reference().child("\(UUID().uuidString)")
//                            storageRef.putData(data, metadata: nil) { (metadata, error) in
////                                guard let metadata = metadata else {
////                                    return
////                                }
//                                if error != nil {
//                                    print("upload error")
//                                } else {
//                                    print("upload successful")
//                                }
//                            }
//                        }
                    }
//                    .disabled(data == nil)
//                    .buttonStyle(.glassProminent)
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

                    guard let imageData else { return }
                    Task {
                        do {
                            try await FirebaseManager.shared.uploadImage(data: imageData)
//                            fm.uploadImage(data: imageData)
                        } catch {
                            print("upload failed: \(error)")
                        }
                    }
                    
//                    fm.uploadImage(data: imageData)
//                    upload()

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
    
//    func upload() {
//        guard let imageData else { return }
//        
//        Task {
//            do {
//                fm.uploadImage(data: imageData)
//            }
//        }
//    }
}

// all for reverse geocoding to get the nearest address to the coordinates
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
        self.address = mapItem.address?.shortAddress ?? "Unknown Address"
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
