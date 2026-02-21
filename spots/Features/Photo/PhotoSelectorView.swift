//
//  PhotoSelectorView.swift
//  spots
//
//  Created by Aiden Gage on 1/16/26.
//
import SwiftUI
import PhotosUI
import Mantis

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

struct ProfilePhotoSelectorView: View {
    @Binding var image: UIImage?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showCropper = false
    @State private var imageToCrop: UIImage?
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 120))
                            .foregroundColor(.gray)
                    )
            }
            
            PhotosPicker(
                selection: $selectedPhoto,
    //            maxSelectionCount: 1,
                matching: .images
            ) {
                Label("Add pfp", systemImage: "photo")
            }
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        imageToCrop = image
                        self.image = image
                        showCropper = true
                    }
//                    await loadProfileImage(item: selectedPhoto)
                }
            }
        }
        .fullScreenCover(isPresented: $showCropper) {
            if let image = imageToCrop {
                MantisCropView(image: image, croppedImage: $image)
            }
        }
        
    }
    
    private func loadProfileImage(item: PhotosPickerItem) async {
        if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
            imageToCrop = image
            showCropper = true
        }
    }
}

struct MantisCropView: UIViewControllerRepresentable {
    let image: UIImage
    @Binding var croppedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIViewController {
        var config = Mantis.Config()
        
        config.cropShapeType = .square
        config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1.0)
        
        let cropVC = Mantis.cropViewController(image: image, config: config)
        cropVC.delegate = context.coordinator
        
        return cropVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: CropViewControllerDelegate {
        let parent: MantisCropView
        
        init(_ base: MantisCropView) {
            self.parent = base
        }
        
        func cropViewControllerDidFailToCrop(_ cropViewController: Mantis.CropViewController, original: UIImage) {
            print("⚠️ Failed to crop image")
            parent.dismiss()
        }
        
        func cropViewControllerDidBeginResize(_ cropViewController: Mantis.CropViewController) {
            print("in crop did begin resize func")
        }
        
        func cropViewControllerDidEndResize(_ cropViewController: Mantis.CropViewController, original: UIImage, cropInfo: Mantis.CropInfo) {
            print("in crop did end resize func")
        }
        
        func cropViewControllerDidCrop(_ cropViewController: CropViewController,
                                       cropped: UIImage,
                                       transformation: Transformation,
                                       cropInfo: CropInfo) {
            print("in crop view controller func")
            parent.croppedImage = cropped
            parent.dismiss()
        }
        
        func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
            print("in crop cancel func")
            parent.dismiss()
        }
    }
}
