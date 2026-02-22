//
//  CameraView.swift
//  spots
//
//  Created by Aiden Gage on 2/21/26.
//
// docs from
// https://www.createwithswift.com/camera-capture-setup-in-a-swiftui-app/

import SwiftUI
//import Foundation
import CoreImage
//import Observation

struct CameraView: View {
    @Environment(\.dismiss)private var dismiss
//    @Binding var image: CGImage?
    @State private var viewModel = ViewModel()
    
    var body: some View {
//        NavigationStack {
            GeometryReader { geometry in
                if let image = viewModel.currentFrame {
                    Image(decorative: image, scale: 1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    ContentUnavailableView("no camera feed", systemImage: "xmark.circle.fill")
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
//            .toolbarBackground(.hidden, for: .navigationBar)
//        }
        
    }
}

@Observable
class ViewModel {
    var currentFrame: CGImage?
    private let cameraManager = CameraManager()
    
    init() {
        Task {
            await handleCameraPreviews()
        }
    }
    
    // handle the updates of the AsyncStream and move the update of the published variables to the MainActor, updating the UI
    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task { @MainActor in
                self.currentFrame = image
            }
        }
    }
    
    
}
