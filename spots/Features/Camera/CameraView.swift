// https://www.youtube.com/watch?v=ik1QRc_kN9M

import SwiftUI
import AVKit
import AVFoundation

enum CaptureMode {
    case photo
    case video
}

struct IdentifiableURL: Identifiable {
    var id = UUID()
    var url: URL
}

struct CameraView: View {
    @StateObject var cameraManager: CameraManager
    @State private var captureMode: CaptureMode = .photo
    
    var body: some View {
        ZStack {
            if cameraManager.authorizationStatus == .authorized {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
            } else {
                HStack {
                    Image(systemName: "camera.fill.badge.xmark")
                        .font(.largeTitle)
                        .foregroundStyle(Color(.systemGray2))
                    Text("Camera Permission Required")
                        .font(.largeTitle)
                        .foregroundStyle(Color(.systemGray2))
                    
                    if cameraManager.authorizationStatus == .denied {
                        Text("please enable camera in settings")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("open settings?") {
                            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared
                                    .open(settingsURL)
                            }
                        }
                        .buttonStyle(.glassProminent)
                    }
                }
            }
            VStack {
                
                HStack {
                    Spacer()
                    Picker("mode", selection: $captureMode) {
                        Text("Photo").tag(CaptureMode.photo)
                        Text("Video").tag(CaptureMode.video)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                    .padding()
                }
                
                Spacer()
                
                if captureMode == .photo {
                    
                    // photo button
                    Button {
                        cameraManager.capturePhoto()
                    } label: {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 70, height: 70)
                            .overlay {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 60, height: 60)
                            }
                    }
                    .ignoresSafeArea()
//                    .padding(.bottom, 10)
                } else {
                    // video button
                    Button {
                        if cameraManager.isRecording {
                            cameraManager.stopRecording()
                        } else {
                            cameraManager.startRecording()
                        }
                    } label: {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 70, height: 70)
                            .overlay {
                                RoundedRectangle(cornerRadius: cameraManager.isRecording ? 6 : 30)
                                    .fill(.red)
                                    .frame(width: cameraManager.isRecording ? 30 : 60, height: cameraManager.isRecording ? 30 : 60)
                            }
                    }
                    .ignoresSafeArea()
                }
                
                if cameraManager.isRecording {
                    HStack {
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)
                        Text("recordin!")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(item: $cameraManager.capturedImage) { item in
                PhotoPreviewView(item: item, onDismiss: {
                    cameraManager.capturedImage = nil
                })
            }
            .sheet(item: $cameraManager.recordedVideoURL) { item in
                VideoPreviewView(item: item, onDismiss: {
                    cameraManager.recordedVideoURL = nil
                })
            }
//            .sheet(item: Binding(
//                get: {cameraManager.recordedVideoURL.map { IdentifiableURL(url: $0)}},
//                set: {cameraManager.recordedVideoURL = $0?.url })) { item in
//                    VideoPreviewView(item: item, onDismiss: {
//                        cameraManager.recordedVideoURL = nil
//                    })
//                }
        }
        .onAppear {
            cameraManager.checkAuth()
        }
    }
}

struct PhotoPreviewView: View {
    let item: IdentifiableImage
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button("retake") {
                    onDismiss()
                }
                .padding()
                
                Spacer()
                
                Button("save") {
                    UIImageWriteToSavedPhotosAlbum(item.image, nil, nil, nil)
                    onDismiss()
                }
                .padding()
            }
            .background(.ultraThinMaterial)
            
            Image(uiImage: item.image)
                .resizable()
                .scaledToFit()
            Spacer()
        }
    }
}

struct VideoPreviewView: View {
    let item: IdentifiableURL
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button("retake") {
                    onDismiss()
                }
                .padding()
                
                Spacer()
                
                Button("save") {
                    UISaveVideoAtPathToSavedPhotosAlbum(item.url.path(), nil, nil, nil)
                    onDismiss()
                }
                .padding()
            }
            .background(.ultraThinMaterial)
            
            VideoPlayer(player: AVPlayer(url: item.url))
        }
    }
}
