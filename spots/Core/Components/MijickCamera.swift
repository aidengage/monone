////
////  MijickCamera.swift
////  spots
////
////  Created by Aiden Gage on 6/17/26.
////
////  https://github.com/Mijick/Camera/wiki/Customizing-MCamera-Screens
//
//import SwiftUI
//import PhotosUI
//import AVFoundation
//import MijickCamera
//
//struct MijickCameraView: View {
//    
//    @Environment(\.dismiss) var dismiss
//    @Environment(\.scenePhase) private var scenePhase
//    
//    @State private var closeCameraAction: (() -> Void)?
//    @Binding var selectedImages: [UIImage]
//    @State private var numCaptures: Int = 0
//    
////    var photoLimit: Int
//    var enablePhoto: Bool = true
////    var enableVideo: Bool
//    @State var showCam: Bool = false
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                MCamera()
//                    .setCameraScreen { cameraManager, id, closeMCameraAction in
//                        let screen = DefaultCameraScreen(cameraManager: cameraManager,
//                                                         namespace: id,
//                                                         closeMCameraAction: closeMCameraAction)
//                            .cameraOutputSwitchAllowed(false)
//
//                        return screen
//                            .onAppear { closeCameraAction = closeMCameraAction } as! (any MCameraScreen)
//                    }
//                    .setAudioAvailability(false)
////                    .setCloseMCameraAction {
////                        showCam = false
////                        print("show cam \(showCam)")
////                    }
//                    .startSession()
////                    .id(camId)
//                    
//            }
//            .onChange(of: scenePhase) { _, new in
//                guard new != .active, let close = closeCameraAction else { return }
//                close()
//            }
////            .onChange(of: scenePhase) { old, new in
////                print("scenePhase: \(old) -> \(new)")
////                guard old == .inactive, new == .active else { return }
////                Task {
////                    await MainActor.run {
////                        print("recreating camera, camId = \(camId)")
////                        camId = UUID()
////                        dismiss
////                    }
////                }
////            }
//        }
////        .onAppear() {
////            print("cam appeared")
////        }
//
//    }
//    
////    private func forceCamRefresh() {
////        camId = UUID()
////    }
//}
//
//struct CamError: MCameraErrorScreen {
//    var error: MijickCamera.MCameraError
//    var closeMCameraAction: () -> ()
//    
//    var body: some View {
//        Button(action: openAppSettings) { Text("Open Settings") }
//    }
//}
//
//struct CamCapturedMedia: MCapturedMediaScreen {
//    var capturedMedia: MijickCamera.MCameraMedia
//    var namespace: Namespace.ID
//    var retakeAction: () -> ()
//    var acceptMediaAction: () -> ()
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            Spacer()
//            createContentView()
//            Spacer()
//            createButtons()
//        }
//    }
//}
//
//private extension CamCapturedMedia {
//    func createContentView() -> some View { ZStack {
//        if let image = capturedMedia.getImage() { createImageView(image) }
//        else { EmptyView() }
//    }}
//    func createButtons() -> some View {
//        HStack(spacing: 24) {
//            createRetakeButton()
//            createSaveButton()
//        }
//    }
//}
//
//private extension CamCapturedMedia {
//    func createImageView(_ image: UIImage) -> some View {
//        Image(uiImage: image)
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .ignoresSafeArea()
//    }
//    func createRetakeButton() -> some View {
//        Button(action: retakeAction) { Text("Retake") }
//    }
//    func createSaveButton() -> some View {
//        Button(action: acceptMediaAction) { Text("Save") }
//    }
//}
//
//struct CamScreen: MCameraScreen {
//    @ObservedObject var cameraManager: MijickCamera.CameraManager
//    var namespace: Namespace.ID
//    var closeMCameraAction: () -> ()
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            createNavigationBar()
//            createCameraOutputView()
//            createCaptureButton()
//        }
//    }
//}
//
//private extension CamScreen {
//    func createNavigationBar() -> some View {
//        Text("This is a custom camera view, replace later")
//            .padding(.top, 12)
//            .padding(.bottom, 12)
//    }
//    func createCaptureButton() -> some View {
//        Button(action: captureOutput) { Text("click to capture")}
//            .padding(.top, 12)
//            .padding(.bottom, 12)
//    }
//}
