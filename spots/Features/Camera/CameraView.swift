// https://www.youtube.com/watch?v=ik1QRc_kN9M

import SwiftUI
import AVKit
import AVFoundation

enum CaptureMode {
    
}

struct CameraView: View {
    @StateObject var cameraManager: CameraManager
    
    var body: some View {
        ZStack {
            if cameraManager.authorizationStatus == .authorized {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
            } else {
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
            VStack {
                Spacer()
                
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
//                .padding(.bottom, 10)
            }
            .sheet(item: $cameraManager.capturedImage) { item in
                PhotoPreviewView(item: item, onDismiss: {
                    cameraManager.capturedImage = nil
                })
            }
        }
        .onAppear {
            cameraManager.checkAuth()
        }
    }
}
