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
        }
    }
}
struct AddPostView: View {
    var body: some View {
        VStack {

            Form {
                Section(header: Text("Add a new post")) {
                    TextField("Title", text: .constant(""))
                    TextField("Description", text: .constant(""))
                    TextField("Address", text: .constant(""))
                }
                Section(header: Text("Image URL")) {
                    PhotosSelector()
//                    TextField("image upload wip", text: .constant(""))
                }
                Section(header: Text("Coordinates")) {
                    HStack {
                        TextField("Latitude", text: .constant(""))
                        TextField("Longitude", text: .constant(""))
                    }
                }
            }
        }
        .navigationTitle("Add Post")
    }
}

#Preview {
    AddPostView()
}
