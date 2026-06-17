//
//  MijickCamera.swift
//  spots
//
//  Created by Aiden Gage on 6/17/26.
//

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

struct CamCaptureMedia: MCapturedMediaScreen {
    var capturedMedia: MCameraMedia
    var namespace: Namespace.ID
    var retakeAction: () -> ()
    var acceptMediaAction: () -> ()
    
    typealias Body = <#type#>
    
    var body: some View {
        
    }
}

struct CamScreen: MCameraScreen {
    var cameraManager: CameraManager
    var namespace: Namespace.ID
    var closeMCameraAction: () -> ()
    
    typealias Body = <#type#>
    
    var body: some View {
        
    }
}
