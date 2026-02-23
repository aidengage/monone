
import SwiftUI
import AVFoundation
import Combine

class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        <#code#>
    }
    
    
    @Published var capturedImage: UIImage?
    @Published var isSessionRunning = false
    @Published var authStatus: AVAuthorizationStatus = .notDetermined
    @Published var isRecording = false
    
    let session = AVCaptureSession()
    
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureMovieFileOutput()
    private var currentInput: AVCaptureDeviceInput?
    
    private let sessionQueue = DispatchQueue(label: "com.monone.camera.sessionQueue")
    
    override init() {
        super.init()
    }
}
