// https://www.youtube.com/watch?v=ik1QRc_kN9M

import SwiftUI
import PhotosUI
import AVKit
import AVFoundation

//    some ideas
//
//  i want to allow a way to limit how many photos a user can take
// to like 5-6, give the option for less but showing button when >zero photo taken
// user is then displayed with a grid of photos to confirm, can retake specific photos
// show empty placeholder spot for slots not taken
//
//  when taking a photo for profile picture, the photo should be put directly
// into the square cropper we use which spits it all the way out to the
// signup view
//
//  maybe think about making firebase manager more similar to how this
// camera manager operates?

enum CaptureMode {
    case photo
    case video
}

enum SwipeDirection {
    case left
    case right
    case up
    case down
}

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct IdentifiableURL: Identifiable {
    var id = UUID()
    var url: URL
}

struct CameraView: View {
    @StateObject var cameraManager: CameraManager
    @State private var captureMode: CaptureMode = .photo
    // default photo limit = 6
    
    @State var swipeDirection = SwipeDirection.left
    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded {
                // Capture swipe direction.
                captureMode = $0.translation.width < 0 ? .photo : .video
            }
    }
    
    var body: some View {
        ZStack {
            if cameraManager.authorizationStatus == .authorized {
                CameraPreview(session: cameraManager.session, cameraManager: cameraManager)
                    .ignoresSafeArea()
                    .simultaneousGesture(swipeGesture)
            } else {
                NoCameraView(authorizationStatus: cameraManager.authorizationStatus)
            }
            
            VStack {
                CameraControlTop(captureMode: $captureMode, cameraManager: cameraManager)
                Spacer()
                CameraControlBottom(captureMode: $captureMode, cameraManager: cameraManager)
            }
            .sheet(item: $cameraManager.capturedImage) { item in
                PhotoPreviewView(cameraManager: cameraManager, item: item, onDismiss: {
                    cameraManager.capturedImage = nil
                })
            }
            .sheet(item: $cameraManager.recordedVideoURL) { item in
                VideoPreviewView(item: item, onDismiss: {
                    cameraManager.recordedVideoURL = nil
                })
            }
        }
        .onAppear {
            cameraManager.checkAuth()
            cameraManager.updateLibraryThumbnail(image: nil)
        }
    }
}

struct PhotoPreviewView: View {
    @ObservedObject var cameraManager: CameraManager
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
                    cameraManager.updateLibraryThumbnail(image: item.image)
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

struct CameraControlTop: View {
    @Binding var captureMode: CaptureMode
    @ObservedObject var cameraManager: CameraManager
    
    private var flashIcon: String {
        switch cameraManager.flashMode {
        case .off:
            return "bolt.slash.fill"
        case .on:
            return "bolt.fill"
        case .auto:
            return "bolt.badge.automatic.fill"
        @unknown default:
            return "bolt.slash.fill"
        }
    }
    
    var body: some View {
        HStack {
            if captureMode == .photo {
                Button {
                    cameraManager.toggleFlash()
                } label: {
                    Image(systemName: flashIcon)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding()
                }
            }
            Spacer()
        }
    }
}

struct CameraControlBottom: View {
    @Binding var captureMode: CaptureMode
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            Color.clear
            VStack {
                Picker("mode", selection: $captureMode) {
                    Text("Photo").tag(CaptureMode.photo)
                    Text("Video").tag(CaptureMode.video)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
                .glassEffect()
                .padding()
                
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
            HStack {
                ThumbnailButton(cameraManager: cameraManager)
                Spacer()
                Button {
                    cameraManager.switchCamera()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                }
                .padding()
            }
        }
    }
}

struct NoCameraView: View {
    let authorizationStatus: AVAuthorizationStatus
    
    var body: some View {
        HStack {
            Image(systemName: "camera.fill.badge.xmark")
                .font(.largeTitle)
                .foregroundStyle(Color(.systemGray2))
            Text("Camera Permission Required")
                .font(.largeTitle)
                .foregroundStyle(Color(.systemGray2))
            
            if authorizationStatus == .denied {
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
}

struct ThumbnailButton: View {
    
    @ObservedObject var cameraManager: CameraManager
    
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        PhotosPicker( selection: $selectedItems, matching: .images, photoLibrary: .shared()) {
            thumbnail
        }
        .frame(width: 64.0, height: 64.0)
        .cornerRadius(8)
        .padding()
//        .disabled(camera.captureActivity.isRecording)
    }
    
    @ViewBuilder
    var thumbnail: some View {
        if let thumbnail = cameraManager.latestThumbnail {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .animation(.easeInOut(duration: 0.3), value: thumbnail)
        } else {
            Rectangle()
                .fill(.gray)
                .frame(width: 64.0, height: 64.0)
        }
    }
}
