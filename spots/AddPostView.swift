//
//  AddPostView.swift
//  spots
//
//  Created by Aiden Gage on 1/4/26.
//

import SwiftUI

struct AddPostView: View {
    @State var title: String = ""
    @State var description: String = ""
    @State var address: String = ""
    @State var imageURL: String = ""
    @State var latitude: Double = 0.0
    @State var longitude: Double = 0.0
    @State var rating: Double = 0.0
    
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
                    TextField("image upload wip", text: $imageURL)
                }
                Section(header: Text("Coordinates")) {
                    HStack {
                        
                        TextField("Latitude", value: $latitude, format: .number)
                            .keyboardType(.decimalPad)
                        TextField("Longitude", value: $longitude, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            let fm = FirebaseManager()
            Button(action: {
                if imageURL.isEmpty || title.isEmpty || address.isEmpty || description.isEmpty || String(rating).isEmpty || String(latitude).isEmpty || String(longitude).isEmpty {
                    print("add every value to post")
                } else {
                    fm.addPost(image: imageURL, name: title, address: address, rating: rating, description: description, coords: (latitude, longitude))
                }
            }) {
                Label("Post!", systemImage: "plus")
            }
            .buttonStyle(.glassProminent)
            .glassEffect()
        }
        .navigationTitle("Add Post")
    }
}

#Preview {
    AddPostView()
}
