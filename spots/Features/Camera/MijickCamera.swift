//
//  MijickCamera.swift
//  spots
//
//  Created by Aiden Gage on 6/17/26.
//
//  https://github.com/Mijick/Camera/wiki/Customizing-MCamera-Screens

import SwiftUI
import PhotosUI
import AVFoundation
import MijickCamera

struct MijickCameraView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var selectedImages: [UIImage]
    @State private var numCaptures: Int = 0
    
    var photoLimit: Int
    var enablePhoto: Bool
    var enableVideo: Bool
    var showConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            MCamera()
                .onImageCaptured { image, controller in
//                saveImageInGallery(image)
                    selectedImages.append(image)
                    controller.reopenCameraScreen()
                }
                .setErrorScreen(CamError.init)
                .setCapturedMediaScreen(CamCapturedMedia.init)
                .startSession()
        }
    }
}

struct CamError: MCameraErrorScreen {
    var error: MCameraError
    var closeMCameraAction: () -> ()
    
    var body: some View {
        Button(action: openAppSettings) { Text("Open Settings") }
    }
}

struct CamCapturedMedia: MCapturedMediaScreen {
    var capturedMedia: MCameraMedia
    var namespace: Namespace.ID
    var retakeAction: () -> ()
    var acceptMediaAction: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            createContentView()
            Spacer()
            createButtons()
        }
    }
    
    private func createContentView() -> some View { ZStack {
        if let image = capturedMedia.getImage() { createImageView(image) }
        else { EmptyView() }
    }}
    private func createButtons() -> some View {
        HStack(spacing: 24) {
            createRetakeButton()
            createSaveButton()
        }
    }
    
    private func createImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .ignoresSafeArea()
    }
    private func createRetakeButton() -> some View {
        Button(action: retakeAction) { Text("Retake") }
    }
    private func createSaveButton() -> some View {
        Button(action: acceptMediaAction) { Text("Save") }
    }
}

struct CamScreen: MCameraScreen {
    var cameraManager: CameraManager
    var namespace: Namespace.ID
    var closeMCameraAction: () -> ()
    
    var body: some View {
        
    }
}
