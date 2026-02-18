//
//  PhotoSelectorView.swift
//  spots
//
//  Created by Aiden Gage on 1/16/26.
//
import SwiftUI
import PhotosUI

// photo selector view, maybe move this to add post view??
struct PhotoSelector: View {
    @Binding var data: [Data]
    @Binding var imageUUIDs: [String]
    @State var selectedItem: [PhotosPickerItem] = []
    @Binding var images: [UIImage]

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images, preferredItemEncoding: .automatic) {
            if !data.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(data, id: \.self) { imageData in
                            if let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame( maxHeight: 300)
                            }
                        }
                    }
                }
            } else {
                Label("Select a picture", systemImage: "photo.on.rectangle.angled")
            }
        }.onChange (of: selectedItem) {_, newValue in
            for item in selectedItem {
                Task {
                    if let imageData = try? await item.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            // add uuid to own array
                            imageUUIDs.append(UUID().uuidString)
//                            images.append(UIImage(data: imageData) ?? UIImage())
                            data.append(imageData)
                            
                            if let image = UIImage(data: imageData) {
                                images.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}

