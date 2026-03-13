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
//
//  swipe up gesture brings up the previewer

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

struct IdentifiableImages: Identifiable {
    var id = UUID()
    var images: [IdentifiableImage]
}

struct IdentifiableURL: Identifiable {
    var id = UUID()
    var url: URL
}

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var cameraManager: CameraManager
    @State private var captureMode: CaptureMode = .photo
    var photoLimit: Int
    @State private var numCaptures: Int = 0
    var enablePhoto: Bool
    var enableVideo: Bool
    var showConfirmation: Bool = false
    @Binding var selectedImages: [UIImage]
    
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
                    .simultaneousGesture(swipeGesture, isEnabled: enablePhoto && enableVideo)
            } else {
                NoCameraView(authorizationStatus: cameraManager.authorizationStatus)
            }
            
            VStack {
                CameraControlTop(captureMode: $captureMode, cameraManager: cameraManager)
                Spacer()
                CameraControlBottom(captureMode: $captureMode, cameraManager: cameraManager, numCaptures: $numCaptures, enablePhoto: enablePhoto, enableVideo: enableVideo)
            }
            .sheet(isPresented: $cameraManager.showBatchPreview) {
//                PhotoPreviewView(cameraManager: cameraManager, item: item, onDismiss: {
//                    cameraManager.capturedImages = []
////                    cameraManager.capturedImage = nil
//                }, numCaptures: $numCaptures)
                BatchPhotoPreviewView(
                    images: cameraManager.capturedImages,
                    onDismiss: {
                        cameraManager.clearCapturedPhotos()
                    },
                    onSave: { images in
                        selectedImages = images
                        dismiss()
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
    let item: IdentifiableImages // change this to []
    let onDismiss: () -> Void
    @Binding var numCaptures: Int
    
    var body: some View {
        VStack {
            HStack {
                Button("retake") {
                    onDismiss()
                }
                .padding()
                
                Spacer()
                
                Button("save") {
                    // make this section a loop / seperate function
                    UIImageWriteToSavedPhotosAlbum(item.images[0].image, nil, nil, nil)
                    cameraManager.updateLibraryThumbnail(image: item.images[0].image)
                    //
                    
                    onDismiss()
                }
                .padding()
            }
            .background(.ultraThinMaterial)
            
            // add grid here
            // go through []
            Image(uiImage: item.images[0].image)
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

struct BatchPhotoPreviewView: View {
    let images: [IdentifiableImage]
    let onDismiss: () -> Void
    let onSave: ([UIImage]) -> Void
    
    @State private var selectedImageIndices: Set<Int> = []
    @State private var currentIndex = 0
    
    init(images: [IdentifiableImage], onDismiss: @escaping () -> Void, onSave: @escaping ([UIImage]) -> Void) {
        self.images = images
        self.onDismiss = onDismiss
        self.onSave = onSave
        // Pre-select all images
        _selectedImageIndices = State(initialValue: Set(images.indices))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button("Retake All") {
                    onDismiss()
                }
                .padding()
                
                Spacer()
                
                Text("\(selectedImageIndices.count) selected")
                    .font(.headline)
                
                Spacer()
                
                Button("Use Photos") {
                    let selectedImages = selectedImageIndices.sorted().compactMap { index in
                        images.indices.contains(index) ? images[index].image : nil
                    }
                    onSave(selectedImages)
                }
                .padding()
                .disabled(selectedImageIndices.isEmpty)
            }
            .background(.ultraThinMaterial)
            
            // Main image viewer
            TabView(selection: $currentIndex) {
                ForEach(images.indices, id: \.self) { index in
                    ZStack {
                        Image(uiImage: images[index].image)
                            .resizable()
                            .scaledToFit()
                        
                        // Selection overlay
                        VStack {
                            HStack {
                                Spacer()
                                
                                Button {
                                    if selectedImageIndices.contains(index) {
                                        selectedImageIndices.remove(index)
                                    } else {
                                        selectedImageIndices.insert(index)
                                    }
                                } label: {
                                    Image(systemName: selectedImageIndices.contains(index) ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                        .shadow(radius: 4)
                                }
                                .padding()
                            }
                            
                            Spacer()
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            // Thumbnail strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(images.indices, id: \.self) { index in
                        Button {
                            currentIndex = index
                        } label: {
                            Image(uiImage: images[index].image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(currentIndex == index ? Color.blue : Color.white, lineWidth: currentIndex == index ? 3 : 1)
                                )
                                .overlay(
                                    Group {
                                        if !selectedImageIndices.contains(index) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.black.opacity(0.5))
                                        }
                                    }
                                )
                                .overlay(
                                    Group {
                                        if selectedImageIndices.contains(index) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                                .font(.title2)
                                        }
                                    },
                                    alignment: .topTrailing
                                )
                        }
                    }
                }
                .padding()
            }
            .frame(height: 120)
            .background(Color.black.opacity(0.8))
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
            if captureMode == .photo {
                Text("\(cameraManager.capturedImages.count)/\(cameraManager.photoLimit)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
            }
        }
    }
}

struct PhotoCaptureButton: View {
//    var captureMode: CaptureMode
    @ObservedObject var cameraManager: CameraManager
    @Binding var numCaptures: Int
    
    var body: some View {
        Button {
            cameraManager.capturePhoto()
            numCaptures += 1
            print("num captures value: \(numCaptures)")
            print("number of button clicks saved: \(String(describing: cameraManager.capturedImages.count))")
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
        .disabled(cameraManager.capturedImages.count >= cameraManager.photoLimit)
        .ignoresSafeArea()
    }
}

struct VideoCaptureButton: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
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
}

struct CameraControlBottom: View {
    @Binding var captureMode: CaptureMode
    @ObservedObject var cameraManager: CameraManager
    @Binding var numCaptures: Int
    var enablePhoto: Bool
    var enableVideo: Bool
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            Color.clear
            VStack {
                if enablePhoto && enableVideo {
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
                        PhotoCaptureButton(cameraManager: cameraManager, numCaptures: $numCaptures)
//                        Button {
//                            cameraManager.capturePhoto()
//                            numCaptures += 1
//                        } label: {
//                            Circle()
//                                .strokeBorder(.white, lineWidth: 3)
//                                .frame(width: 70, height: 70)
//                                .overlay {
//                                    Circle()
//                                        .fill(.white)
//                                        .frame(width: 60, height: 60)
//                                }
//                        }
//                        .ignoresSafeArea()
                    } else {
                        // video button
                        VideoCaptureButton(cameraManager: cameraManager)
//                        Button {
//                            if cameraManager.isRecording {
//                                cameraManager.stopRecording()
//                            } else {
//                                cameraManager.startRecording()
//                            }
//                        } label: {
//                            Circle()
//                                .strokeBorder(.white, lineWidth: 3)
//                                .frame(width: 70, height: 70)
//                                .overlay {
//                                    RoundedRectangle(cornerRadius: cameraManager.isRecording ? 6 : 30)
//                                        .fill(.red)
//                                        .frame(width: cameraManager.isRecording ? 30 : 60, height: cameraManager.isRecording ? 30 : 60)
//                                }
//                        }
//                        .ignoresSafeArea()
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
                } else if enablePhoto && !enableVideo {
                    PhotoCaptureButton(cameraManager: cameraManager, numCaptures: $numCaptures)
                } else if !enablePhoto && enableVideo {
                    VideoCaptureButton(cameraManager: cameraManager)
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

#Preview {
    
}

