//
//  AddPostView.swift
//  spots
//
//  Created by Aiden Gage on 1/4/26.
//

import SwiftUI
import PhotosUI

struct PhotosSelector: View {
    @State var selectedItems: [PhotosPickerItem] = []


    var body: some View {
        PhotosPicker(selection: $selectedItems,
                     matching: .images) {
            Text("Select Multiple Photos")
//            Button(action: {
//                howManyPhotos()
//            }) {
//                Text("print")
//            }
//            Button(action: {
//                storePhotos(selectedImages: selectedItems)
//            }) {
//                Text("Select Multiple Photos")
//            }
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
                    TextField("Rating", value: $rating, format: .number)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Image URL")) {
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
                if imageURL.isEmpty || title.isEmpty || address.isEmpty || description.isEmpty || rating == 0.0 || centerLat == 0.0 || centerLong == 0.0 {
                    print("add every value to post")
                } else {
                    fm.addPost(image: imageURL, name: title, address: address, rating: rating, description: description, coords: (centerLat, centerLong))
                    
                    // should reset values but doesnt i guess
                    title = ""
                    description = ""
                    address = ""
                    imageURL = ""
                    centerLat = 0.0
                    centerLong = 0.0
                    rating = 0.0
                    
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
    }
}

#Preview {
    AddPostView(centerLat: 0.0, centerLong: 0.0)
}
