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
            //            .setErrorScreen()
                .startSession()
        }
    }
}
